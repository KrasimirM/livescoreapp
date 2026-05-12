import 'package:LiveScore/Screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/FirestoreService.dart';
import '../Widgets/ProfileScreenTile.dart';
import '../Widgets/LoadingView.dart';
import 'LeagueSelectionScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? favoriteTeamName;
  String? userEmail;
  bool _isLoading = true;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchFavoriteTeam();
  }

  Future<void> _fetchFavoriteTeam() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
      Map<String, dynamic> userData =
          await _firestoreService.getUserData(user.uid);
      final teamName = (userData['favorite_team'] ?? '').toString().trim();
      setState(() {
        favoriteTeamName = teamName.isEmpty ? null : teamName;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: _isLoading
            ? LoadingView(message: 'Loading profile...')
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    if (userEmail != null)
                      ProfileScreenTile(name: 'Email', label: userEmail ?? ''),
                    SizedBox(height: 20),
                    ProfileScreenTile(
                      name: 'Favorite Team',
                      label: favoriteTeamName ?? 'No favorite team selected',
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _changeFavoriteTeam(context);
                      },
                      child: Text('Change Favorite Team'),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        _signOut(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate directly to login screen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void _changeFavoriteTeam(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeagueSelectionScreen()),
    );
    if (result != null) {
      setState(() {
        favoriteTeamName = result['name'];
      });
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestoreService.updateFavoriteTeam(
          user.email ?? '',
          result['name'],
          result['id'],
        );
      }
    }
  }
}
