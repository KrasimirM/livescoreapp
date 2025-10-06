import 'package:LiveScore/Widgets/MatchFilter.dart';
import 'package:LiveScore/Widgets/MatchTile.dart';
import 'package:LiveScore/Widgets/TeamInfo.dart';
import 'package:LiveScore/Widgets/MatchSection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:LiveScore/services/HttpService.dart';
import 'package:LiveScore/services/FirestoreService.dart';
import 'LeagueSelectionScreen.dart';

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
  List _pastMatches = [];
  List _futureMatches = [];
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HttpService _httpService = HttpService();

  String _selectedFilter = 'upcoming';

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
            ? TeamInfo(
                teamName: _favoriteTeamName!,
                crestUrl: _favoriteTeamCrest!,
              )
            : Container(),
        SizedBox(height: 20),
        _matches.isEmpty
            ? CircularProgressIndicator()
            : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLastPlayedMatch(),
                      SizedBox(height: 20),
                      MatchFilter(
                        selectedFilter: _selectedFilter,
                        onChanged: (String newValue) {
                          setState(() {
                            _selectedFilter = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      _buildMatchList(),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildLastPlayedMatch() {
    if (_pastMatches.isEmpty) return Container();

    final lastMatch = _pastMatches.first;
    return Column(
      children: [
        Text(
          'Last Played Match',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        MatchTile(match: lastMatch),
      ],
    );
  }

  Widget _buildMatchList() {
    List matchesToDisplay =
        _selectedFilter == 'past' ? _pastMatches : _futureMatches;

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: matchesToDisplay.length,
      itemBuilder: (context, index) {
        return MatchTile(match: matchesToDisplay[index]);
      },
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

  Future<void> getMatches() async {
    try {
      final now = DateTime.now();
      final oneYearAgo =
          DateTime(now.year - 1, now.month, now.day).toString().split(' ')[0];
      final today = now.toString().split(' ')[0];

      final pastMatches = await _httpService.fetchMatches(_favoriteTeamId!,
          dateFrom: oneYearAgo, dateTo: today);

      final nextYear =
          DateTime(now.year + 1, now.month, now.day).toString().split(' ')[0];
      final futureMatches = await _httpService.fetchMatches(_favoriteTeamId!,
          dateFrom: today, dateTo: nextYear);

      pastMatches.sort((a, b) =>
          DateTime.parse(b['utcDate']).compareTo(DateTime.parse(a['utcDate'])));

      setState(() {
        _pastMatches = pastMatches;
        _futureMatches = futureMatches;
        _matches = _futureMatches;
      });
    } catch (e) {
      print('Error fetching matches: $e');
    }
  }

  void getTeamDetails(String teamId) async {
    try {
      final crest = await _httpService.fetchTeamDetails(teamId);
      setState(() {
        _favoriteTeamCrest = crest;
      });
    } catch (e) {
      print('Error fetching team details: $e');
    }
  }
}
