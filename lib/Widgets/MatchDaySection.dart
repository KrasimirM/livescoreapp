import 'package:LiveScore/Screens/UpcomingMatchScreen.dart';
import 'package:LiveScore/Widgets/CrestImage.dart';
import 'package:LiveScore/constants.dart';
import 'package:LiveScore/services/FirestoreService.dart';
import 'package:LiveScore/services/HttpService.dart';
import 'package:LiveScore/services/NotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MatchDaySection extends StatefulWidget {
  const MatchDaySection({Key? key}) : super(key: key);

  @override
  State<MatchDaySection> createState() => _MatchDaySectionState();
}

class _MatchDaySectionState extends State<MatchDaySection> {
  final HttpService _httpService = HttpService();
  final FirestoreService _firestoreService = FirestoreService();
  final PageController _pageController = PageController(viewportFraction: 0.88);
  late Future<List<Map<String, dynamic>>> _matchesFuture;
  late Future<Map<String, dynamic>?> _pinnedFuture;
  int _interactionRefreshToken = 0;

  static const _competitionCodes = ['PL', 'CL', 'PD', 'BL1', 'SA', 'WC'];

  @override
  void initState() {
    super.initState();
    _matchesFuture = _fetchMatchDayMatches();
    _refreshStats();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _refreshStats() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _pinnedFuture = userId.isEmpty
        ? Future.value(null)
        : _firestoreService.getPinnedMatch(userId);
    _interactionRefreshToken++;
  }

  Future<void> _openMatch(Map<String, dynamic> match) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UpcomingMatchScreen(match: match)),
    );
    if (!mounted) return;
    setState(_refreshStats);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _matchesFuture,
      builder: (context, snapshot) {
        final matches = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Match Day',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Swipe, pin and track kickoffs',
                          style: TextStyle(
                            color: AppColors.mutedTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _matchesFuture = _fetchMatchDayMatches();
                        _refreshStats();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: _pinnedFuture,
                builder: (context, pinnedSnapshot) {
                  final pinned = pinnedSnapshot.data;
                  if (pinned == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PinnedMatchCard(
                      match: Map<String, dynamic>.from(pinned['match'] ?? {}),
                      onOpen: _openMatch,
                    ),
                  );
                },
              ),
            ),
            if (!snapshot.hasData)
              const SizedBox(
                height: 190,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              )
            else if (matches.isEmpty)
              const _MatchDayEmptyCard()
            else
              SizedBox(
                height: 210,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _MatchDayCard(
                        match: matches[index],
                        refreshToken: _interactionRefreshToken,
                        onOpen: _openMatch,
                        onChanged: () {
                          setState(_refreshStats);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchMatchDayMatches() async {
    final now = DateTime.now();
    final end = now.add(const Duration(days: 7));
    final allMatches = <Map<String, dynamic>>[];

    for (final code in _competitionCodes) {
      try {
        final matches = await _httpService.fetchCompetitionMatches(code);
        for (final match in matches) {
          if (match is! Map) continue;
          final parsed = DateTime.tryParse((match['utcDate'] ?? '').toString());
          if (parsed == null) continue;
          final local = parsed.toLocal();
          if (local.isBefore(now.subtract(const Duration(hours: 2)))) continue;
          if (local.isAfter(end)) continue;
          allMatches.add(Map<String, dynamic>.from(match));
        }
      } catch (_) {
        continue;
      }
    }

    allMatches.sort((a, b) => DateTime.parse(a['utcDate'])
        .toLocal()
        .compareTo(DateTime.parse(b['utcDate']).toLocal()));
    return allMatches.take(12).toList();
  }
}

class _PinnedMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final ValueChanged<Map<String, dynamic>> onOpen;

  const _PinnedMatchCard({
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
              _countdownText(match['utcDate']),
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

class _MatchDayCard extends StatefulWidget {
  final Map<String, dynamic> match;
  final int refreshToken;
  final ValueChanged<Map<String, dynamic>> onOpen;
  final VoidCallback onChanged;

  const _MatchDayCard({
    required this.match,
    required this.refreshToken,
    required this.onOpen,
    required this.onChanged,
  });

  @override
  State<_MatchDayCard> createState() => _MatchDayCardState();
}

class _MatchDayCardState extends State<_MatchDayCard> {
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
  void didUpdateWidget(covariant _MatchDayCard oldWidget) {
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
                _IconToggle(
                  icon: Icons.notifications_active,
                  selected: _reminder,
                  disabled: _loadingInteraction,
                  onTap: _toggleReminder,
                ),
                const SizedBox(width: 6),
                _IconToggle(
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
                _CardTeam(team: homeTeam),
                _CountdownBadge(date: match['utcDate']),
                _CardTeam(team: awayTeam),
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

class _CardTeam extends StatelessWidget {
  final dynamic team;

  const _CardTeam({required this.team});

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

class _CountdownBadge extends StatelessWidget {
  final dynamic date;

  const _CountdownBadge({required this.date});

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
            _countdownText(date),
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

class _IconToggle extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _IconToggle({
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

class _MatchDayEmptyCard extends StatelessWidget {
  const _MatchDayEmptyCard();

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

String _countdownText(dynamic rawDate) {
  final parsed = DateTime.tryParse((rawDate ?? '').toString());
  if (parsed == null) return 'TBD';
  final diff = parsed.toLocal().difference(DateTime.now());
  if (diff.isNegative) return 'Live';
  if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
  if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
  return '${diff.inMinutes}m';
}
