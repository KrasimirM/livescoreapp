import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'LeagueSelectionScreen.dart';
import 'package:LiveScore/Widgets/MatchTile.dart';
import '../services/FirestoreService.dart';

class Favouriteteamscreen extends StatefulWidget {
  const Favouriteteamscreen({Key? key}) : super(key: key);

  @override
  State<Favouriteteamscreen> createState() => _FavouriteteamscreenState();
}

class _FavouriteteamscreenState extends State<Favouriteteamscreen> {
  String? _favoriteTeamName;
  String? _favoriteTeamId;
  String? _favoriteTeamCrest;
  List _matches = [];
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;
        Map<String, dynamic> userData =
            await _firestoreService.getUserData(uid);
        if (userData['favorite_team'] != null &&
            userData['favorite_team_id'] != null) {
          setState(() {
            _favoriteTeamName = userData['favorite_team'];
            _favoriteTeamId = userData['favorite_team_id'];
          });
          getMatches();
          getTeamDetails(_favoriteTeamId!);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Favorite Team'),
      ),
      body: Center(
        child: _favoriteTeamName == null
            ? _buildNoFavoriteTeam()
            : _buildFavoriteTeam(),
      ),
    );
  }

  Widget _buildNoFavoriteTeam() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('No favourite team selected'),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LeagueSelectionScreen()),
            );
            if (result != null) {
              setState(() {
                _favoriteTeamName = result['name'];
                _favoriteTeamId = result['id'];
              });
              getMatches();
              getTeamDetails(_favoriteTeamId!);
              _saveFavoriteTeam();
            }
          },
          child: Text('Select Favourite Team'),
        ),
      ],
    );
  }

  Widget _buildFavoriteTeam() {
    return Column(
      children: [
        SizedBox(height: 20),
        _favoriteTeamCrest != null
            ? Image.network(_favoriteTeamCrest!, height: 100)
            : Container(),
        Text('$_favoriteTeamName'),
        SizedBox(height: 20),
        _matches.isEmpty
            ? CircularProgressIndicator()
            : Expanded(
                child: ListView.builder(
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = _matches.length - 1 - index;
                    return MatchTile(match: _matches[reversedIndex]);
                  },
                ),
              ),
      ],
    );
  }

  void _saveFavoriteTeam() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String email = user.email ?? '';
      await _firestoreService.updateFavoriteTeam(
          email, _favoriteTeamName!, _favoriteTeamId!);
    }
  }

  void getMatches() async {
    final now = DateTime.now();
    final oneYearAgo =
        DateTime(now.year - 1, now.month, now.day).toString().split(' ')[0];
    final today = now.toString().split(' ')[0];
    final url =
        'http://api.football-data.org/v4/teams/$_favoriteTeamId/matches?dateFrom=$oneYearAgo&dateTo=$today&sortBy=date';
    final response = await http.get(
      Uri.parse(url),
      headers: {'X-Auth-Token': '27f54ff1ab4b4d2cbbb3d0c34084d70a'},
    );
    final data = jsonDecode(response.body);
    setState(() {
      _matches = data['matches'];
    });
  }

  void getTeamDetails(String teamId) async {
    final url = 'http://api.football-data.org/v4/teams/$teamId';
    final response = await http.get(
      Uri.parse(url),
      headers: {'X-Auth-Token': '27f54ff1ab4b4d2cbbb3d0c34084d70a'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _favoriteTeamCrest = data['crest'];
      });
    } else {
      print('Failed to load team details: ${response.statusCode}');
    }
  }
}
