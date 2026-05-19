import 'package:LiveScore/Screens/LoginScreen.dart';
import 'package:LiveScore/Screens/UpcomingMatchScreen.dart';
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
                  _ProfileHero(
                    email: userEmail ?? 'Unknown user',
                    favoriteTeam:
                        favoriteTeamName ?? 'No favorite team selected',
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniMetric(
                          icon: Icons.star,
                          label: 'Favorite',
                          value: favoriteTeamName == null ? 'Open' : 'Set',
                          color: AppColors.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _MiniMetric(
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
                        return _PinnedProfileMatch(
                          match: Map<String, dynamic>.from(
                            pinned['match'] ?? {},
                          ),
                          onOpen: _openPinnedMatch,
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                  ],
                  _SectionTitle(title: 'Quick Actions'),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.swap_horiz,
                    title: favoriteTeamName == null
                        ? 'Choose favorite team'
                        : 'Change favorite team',
                    subtitle: 'Pick the club used on your team dashboard',
                    color: AppColors.primaryColor,
                    onTap: () => _changeFavoriteTeam(context),
                  ),
                  _ActionTile(
                    icon: Icons.emoji_events,
                    title: 'Browse competitions',
                    subtitle: 'Tables, brackets and match details',
                    color: AppColors.secondaryAccentColor,
                    onTap: () => widget.onNavigate?.call(0),
                  ),
                  _ActionTile(
                    icon: Icons.psychology_alt,
                    title: 'Quiz hub',
                    subtitle: 'Play quizzes and track ranking',
                    color: AppColors.accentColor,
                    onTap: () => widget.onNavigate?.call(2),
                  ),
                  _ActionTile(
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

class _PinnedProfileMatch extends StatelessWidget {
  final Map<String, dynamic> match;
  final ValueChanged<Map<String, dynamic>> onOpen;

  const _PinnedProfileMatch({
    required this.match,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (match.isEmpty) return const SizedBox.shrink();
    final home = match['homeTeam'] ?? {};
    final away = match['awayTeam'] ?? {};

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onOpen(match),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.accentColor.withAlpha(28),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentColor.withAlpha(85)),
        ),
        child: Row(
          children: [
            const Icon(Icons.push_pin, color: AppColors.accentColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pinned Match',
                    style: TextStyle(
                      color: AppColors.mutedTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${home['shortName'] ?? home['name']} vs ${away['shortName'] ?? away['name']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: AppColors.accentColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final String email;
  final String favoriteTeam;

  const _ProfileHero({
    required this.email,
    required this.favoriteTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(235),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.secondaryAccentColor,
                ],
              ),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.backgroundColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  favoriteTeam,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.subtitleTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor.withAlpha(235),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.mutedTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(225),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withAlpha(35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.subtitleTextColor),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.mutedTextColor,
        ),
      ),
    );
  }
}
