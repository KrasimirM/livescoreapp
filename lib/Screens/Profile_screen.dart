import 'package:LiveScore/Screens/LoginScreen.dart';
import 'package:LiveScore/Screens/UpcomingMatchScreen.dart';
import 'package:LiveScore/Widgets/ProfileComponents.dart';
import 'package:LiveScore/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/FirestoreService.dart';
import '../Widgets/LoadingView.dart';
import 'LeagueSelectionScreen.dart';

class ProfileScreen extends StatefulWidget {
  final int refreshToken;
  final ValueChanged<int>? onNavigate;
  final VoidCallback? onFavoriteTeamChanged;

  const ProfileScreen({
    Key? key,
    this.refreshToken = 0,
    this.onNavigate,
    this.onFavoriteTeamChanged,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? favoriteTeamName;
  String? userEmail;
  bool _isLoading = true;
  Future<Map<String, dynamic>?>? _pinnedMatchFuture;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchFavoriteTeam();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _fetchFavoriteTeam();
    }
  }

  Future<void> _fetchFavoriteTeam() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
        _pinnedMatchFuture = _firestoreService.getPinnedMatch(user.uid);
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
      body: _isLoading
          ? LoadingView(message: 'Loading profile...')
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 96),
                physics: const BouncingScrollPhysics(),
                children: [
                  ProfileHero(
                    email: userEmail ?? 'Unknown user',
                    favoriteTeam:
                        favoriteTeamName ?? 'No favorite team selected',
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: MiniMetric(
                          icon: Icons.star,
                          label: 'Favorite',
                          value: favoriteTeamName == null ? 'Open' : 'Set',
                          color: AppColors.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: MiniMetric(
                          icon: Icons.verified_user,
                          label: 'Account',
                          value: 'Active',
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (_pinnedMatchFuture != null) ...[
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _pinnedMatchFuture,
                      builder: (context, snapshot) {
                        final pinned = snapshot.data;
                        if (pinned == null) return const SizedBox.shrink();
                        return PinnedProfileMatch(
                          match: Map<String, dynamic>.from(
                            pinned['match'] ?? {},
                          ),
                          onOpen: _openPinnedMatch,
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                  ],
                  const SectionTitle(title: 'Quick Actions'),
                  const SizedBox(height: 10),
                  ProfileActionTile(
                    icon: Icons.swap_horiz,
                    title: favoriteTeamName == null
                        ? 'Choose favorite team'
                        : 'Change favorite team',
                    subtitle: 'Pick the club used on your team dashboard',
                    color: AppColors.primaryColor,
                    onTap: () => _changeFavoriteTeam(context),
                  ),
                  ProfileActionTile(
                    icon: Icons.emoji_events,
                    title: 'Browse competitions',
                    subtitle: 'Tables, brackets and match details',
                    color: AppColors.secondaryAccentColor,
                    onTap: () => widget.onNavigate?.call(0),
                  ),
                  ProfileActionTile(
                    icon: Icons.psychology_alt,
                    title: 'Quiz hub',
                    subtitle: 'Play quizzes and track ranking',
                    color: AppColors.accentColor,
                    onTap: () => widget.onNavigate?.call(2),
                  ),
                  ProfileActionTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'End this session on the device',
                    color: AppColors.errorColor,
                    onTap: () => _signOut(context),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
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
      final teamName = result['name'].toString();
      final teamId = result['id'].toString();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestoreService.updateFavoriteTeam(
          user.email ?? '',
          teamName,
          teamId,
        );
      }
      if (!mounted) return;
      setState(() {
        favoriteTeamName = teamName;
      });
      widget.onFavoriteTeamChanged?.call();
    }
  }

  Future<void> _openPinnedMatch(Map<String, dynamic> match) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UpcomingMatchScreen(match: match)),
    );
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted || user == null) return;
    setState(() {
      _pinnedMatchFuture = _firestoreService.getPinnedMatch(user.uid);
    });
  }
}
