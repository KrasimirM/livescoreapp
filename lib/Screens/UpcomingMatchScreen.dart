import 'package:flutter/material.dart';
import 'package:LiveScore/Widgets/UpcomingMatchPreview.dart';
import 'package:LiveScore/constants.dart';
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
                  MatchHero(
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                    dateText: dateText,
                    countdownText: matchCountdownText(widget.match['utcDate']),
                    reminder: _reminder,
                    pinned: _pinned,
                    onReminderTap: _toggleReminder,
                    onPinTap: _togglePinned,
                  ),
                  const SizedBox(height: 18),
                  if (stats != null && stats!.isNotEmpty)
                    PredictionPanel(stats: stats!)
                  else
                    const NoStatsCard(),
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
