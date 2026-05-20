import 'package:LiveScore/Widgets/CrestImage.dart';
import 'package:LiveScore/constants.dart';
import 'package:LiveScore/services/FirestoreService.dart';
import 'package:LiveScore/services/NotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinnedMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final ValueChanged<Map<String, dynamic>> onOpen;

  const PinnedMatchCard({
    super.key,
    required this.match,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final home = match['homeTeam'] ?? {};
    final away = match['awayTeam'] ?? {};
    if (match.isEmpty) return const SizedBox.shrink();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onOpen(match),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accentColor.withAlpha(28),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentColor.withAlpha(85)),
        ),
        child: Row(
          children: [
            const Icon(Icons.push_pin, color: AppColors.accentColor, size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                '${home['shortName'] ?? home['name']} vs ${away['shortName'] ?? away['name']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              countdownText(match['utcDate']),
              style: const TextStyle(
                color: AppColors.accentColor,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchDayCard extends StatefulWidget {
  final Map<String, dynamic> match;
  final int refreshToken;
  final ValueChanged<Map<String, dynamic>> onOpen;
  final VoidCallback onChanged;

  const MatchDayCard({
    super.key,
    required this.match,
    required this.refreshToken,
    required this.onOpen,
    required this.onChanged,
  });

  @override
  State<MatchDayCard> createState() => _MatchDayCardState();
}

class _MatchDayCardState extends State<MatchDayCard> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _reminder = false;
  bool _pinned = false;
  bool _loadingInteraction = true;

  @override
  void initState() {
    super.initState();
    _loadInteraction();
  }

  @override
  void didUpdateWidget(covariant MatchDayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match['id'] != widget.match['id'] ||
        oldWidget.refreshToken != widget.refreshToken) {
      _loadInteraction();
    }
  }

  Future<void> _loadInteraction() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _loadingInteraction = false);
      return;
    }

    final matchId = widget.match['id'].toString();
    final interaction =
        await _firestoreService.getMatchInteraction(userId, matchId);
    if (!mounted) return;
    setState(() {
      _reminder = interaction?['reminderEnabled'] == true;
      _pinned = interaction?['pinned'] == true;
      _loadingInteraction = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final homeTeam = match['homeTeam'] ?? {};
    final awayTeam = match['awayTeam'] ?? {};
    final competition = match['competition']?['name'] ?? 'Match';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => widget.onOpen(match),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withAlpha(55),
              AppColors.cardBackgroundColor.withAlpha(245),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryColor.withAlpha(80)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    competition.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.mutedTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconToggle(
                  icon: Icons.notifications_active,
                  selected: _reminder,
                  disabled: _loadingInteraction,
                  onTap: _toggleReminder,
                ),
                const SizedBox(width: 6),
                IconToggle(
                  icon: Icons.push_pin,
                  selected: _pinned,
                  disabled: _loadingInteraction,
                  onTap: _togglePinned,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CardTeam(team: homeTeam),
                CountdownBadge(date: match['utcDate']),
                CardTeam(team: awayTeam),
              ],
            ),
          ],
        ),
      ),
    );
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
      widget.onChanged();
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
      widget.onChanged();
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

class CardTeam extends StatelessWidget {
  final dynamic team;

  const CardTeam({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CrestImage(
            crestUrl: team['crest'],
            width: 42,
            height: 42,
          ),
          const SizedBox(height: 7),
          Text(
            (team['shortName'] ?? team['name'] ?? '').toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class CountdownBadge extends StatelessWidget {
  final dynamic date;

  const CountdownBadge({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text(
            'Kickoff',
            style: TextStyle(
              color: AppColors.backgroundColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            countdownText(date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.backgroundColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class IconToggle extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const IconToggle({
    super.key,
    required this.icon,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: disabled ? null : onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentColor.withAlpha(45)
              : AppColors.surfaceColor.withAlpha(210),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selected ? AppColors.accentColor : Colors.white.withAlpha(12),
          ),
        ),
        child: Icon(
          icon,
          color: selected ? AppColors.accentColor : AppColors.mutedTextColor,
          size: 18,
        ),
      ),
    );
  }
}

class MatchDayEmptyCard extends StatelessWidget {
  const MatchDayEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(232),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: const Row(
        children: [
          Icon(Icons.event_busy, color: AppColors.accentColor),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No upcoming match day cards for the next week.',
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

String countdownText(dynamic rawDate) {
  final parsed = DateTime.tryParse((rawDate ?? '').toString());
  if (parsed == null) return 'TBD';
  final diff = parsed.toLocal().difference(DateTime.now());
  if (diff.isNegative) return 'Live';
  if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
  if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
  return '${diff.inMinutes}m';
}
