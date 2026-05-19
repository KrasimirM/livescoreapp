import 'package:flutter/material.dart';
import 'package:LiveScore/constants.dart';
import 'package:LiveScore/Widgets/CrestImage.dart';
import 'package:LiveScore/services/FirestoreService.dart';
import 'package:LiveScore/services/MatchPredictionService.dart';
import 'package:LiveScore/services/NotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class UpcomingMatchScreen extends StatefulWidget {
  final Map match;

  const UpcomingMatchScreen({required this.match});

  @override
  _UpcomingMatchScreenState createState() => _UpcomingMatchScreenState();
}

class _UpcomingMatchScreenState extends State<UpcomingMatchScreen> {
  final MatchPredictionService _predictionService = MatchPredictionService();
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? stats;
  bool loading = true;
  bool _reminder = false;
  bool _pinned = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadInteraction();
  }

  void _loadStats() async {
    try {
      final data = await _predictionService.fetchHeadToHeadPrediction(
          widget.match['id'].toString(), widget.match);
      setState(() {
        stats = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        stats = {};
        loading = false;
      });
    }
  }

  void _loadInteraction() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final matchId = widget.match['id'].toString();
    final interaction =
        await _firestoreService.getMatchInteraction(userId, matchId);
    if (!mounted) return;
    setState(() {
      _reminder = interaction?['reminderEnabled'] == true;
      _pinned = interaction?['pinned'] == true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeTeam = widget.match['homeTeam'];
    final awayTeam = widget.match['awayTeam'];
    final dateText = _formatMatchDate(widget.match['utcDate']);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Match Preview'),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _MatchHero(
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                    dateText: dateText,
                    countdownText: _countdownText(widget.match['utcDate']),
                    reminder: _reminder,
                    pinned: _pinned,
                    onReminderTap: _toggleReminder,
                    onPinTap: _togglePinned,
                  ),
                  const SizedBox(height: 18),
                  if (stats != null && stats!.isNotEmpty)
                    _PredictionPanel(stats: stats!)
                  else
                    const _NoStatsCard(),
                ],
              ),
            ),
    );
  }

  String _formatMatchDate(dynamic rawDate) {
    final parsed = DateTime.tryParse((rawDate ?? '').toString());
    if (parsed == null) return 'Date not confirmed';
    final local = parsed.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day}.${local.month}.${local.year}  $hour:$minute';
  }

  Future<void> _toggleReminder() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    HapticFeedback.selectionClick();
    final next = !_reminder;
    setState(() => _reminder = next);
    try {
      if (next) {
        await NotificationService.scheduleMatchReminder(widget.match);
      }
      await _firestoreService.setMatchReminder(
        userId: userId,
        match: widget.match,
        enabled: next,
      );
      if (!next) {
        await NotificationService.cancelMatchReminder(widget.match);
      }
      if (next && mounted) {
        _showMessage('Notification scheduled.');
      }
    } catch (_) {
      if (next) await NotificationService.cancelMatchReminder(widget.match);
      if (!mounted) return;
      setState(() => _reminder = !next);
      _showMessage('Could not schedule this notification.');
    }
  }

  Future<void> _togglePinned() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    HapticFeedback.mediumImpact();
    final next = !_pinned;
    setState(() => _pinned = next);
    try {
      await _firestoreService.setPinnedMatch(
        userId: userId,
        match: widget.match,
        pinned: next,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _pinned = !next);
      _showMessage('Could not update this match right now.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

class _MatchHero extends StatelessWidget {
  final Map homeTeam;
  final Map awayTeam;
  final String dateText;
  final String countdownText;
  final bool reminder;
  final bool pinned;
  final VoidCallback onReminderTap;
  final VoidCallback onPinTap;

  const _MatchHero({
    required this.homeTeam,
    required this.awayTeam,
    required this.dateText,
    required this.countdownText,
    required this.reminder,
    required this.pinned,
    required this.onReminderTap,
    required this.onPinTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withAlpha(58),
            AppColors.cardBackgroundColor.withAlpha(245),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accentColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kickoff in',
                        style: TextStyle(
                          color: AppColors.backgroundColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        countdownText,
                        style: const TextStyle(
                          color: AppColors.backgroundColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        dateText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.backgroundColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _HeroToggle(
                icon: Icons.notifications_active,
                selected: reminder,
                onTap: onReminderTap,
              ),
              const SizedBox(width: 8),
              _HeroToggle(
                icon: Icons.push_pin,
                selected: pinned,
                onTap: onPinTap,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _TeamBadge(team: homeTeam)),
              const _VersusMark(),
              Expanded(child: _TeamBadge(team: awayTeam)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroToggle extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _HeroToggle({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor.withAlpha(60)
              : AppColors.surfaceColor.withAlpha(220),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color:
                selected ? AppColors.primaryColor : Colors.white.withAlpha(16),
          ),
        ),
        child: Icon(
          icon,
          color: selected ? AppColors.primaryColor : AppColors.mutedTextColor,
        ),
      ),
    );
  }
}

String _countdownText(dynamic rawDate) {
  final parsed = DateTime.tryParse((rawDate ?? '').toString());
  if (parsed == null) return 'TBD';
  final diff = parsed.toLocal().difference(DateTime.now());
  if (diff.isNegative) return 'Live';
  if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
  if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
  return '${diff.inMinutes}m';
}

class _VersusMark extends StatelessWidget {
  const _VersusMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accentColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withAlpha(70),
            blurRadius: 18,
          ),
        ],
      ),
      child: const Text(
        'VS',
        style: TextStyle(
          color: AppColors.backgroundColor,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _TeamBadge extends StatelessWidget {
  final Map team;

  const _TeamBadge({required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: CrestImage(
            crestUrl: team['crest'],
            width: 58,
            height: 58,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          team['name'] ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PredictionPanel extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _PredictionPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    final homeChance = _chanceValue(stats['homeTeam']['chance']);
    final drawChance = _chanceValue(stats['draw']);
    final awayChance = _chanceValue(stats['awayTeam']['chance']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(235),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, color: AppColors.primaryColor),
              SizedBox(width: 8),
              Text(
                'Predicted Chances',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ChanceTile(
            label: '${stats['homeTeam']['name']} Win',
            chance: homeChance,
            color: AppColors.primaryColor,
            icon: Icons.home,
          ),
          _ChanceTile(
            label: 'Draw',
            chance: drawChance,
            color: AppColors.secondaryAccentColor,
            icon: Icons.balance,
          ),
          _ChanceTile(
            label: '${stats['awayTeam']['name']} Win',
            chance: awayChance,
            color: AppColors.accentColor,
            icon: Icons.flight_takeoff,
          ),
        ],
      ),
    );
  }

  double _chanceValue(dynamic value) {
    if (value is num) return value.toDouble().clamp(0, 100);
    return double.tryParse(value.toString())?.clamp(0, 100) ?? 0;
  }
}

class _ChanceTile extends StatelessWidget {
  final String label;
  final double chance;
  final Color color;
  final IconData icon;

  const _ChanceTile({
    required this.label,
    required this.chance,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor.withAlpha(220),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withAlpha(85)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${chance.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: chance / 100,
              color: color,
              backgroundColor: Colors.white.withAlpha(18),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoStatsCard extends StatelessWidget {
  const _NoStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(235),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.accentColor),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No prediction stats available for this match yet.',
              style: TextStyle(
                color: AppColors.subtitleTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
