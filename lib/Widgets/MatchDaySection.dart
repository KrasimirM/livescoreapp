import 'package:LiveScore/Screens/UpcomingMatchScreen.dart';
import 'package:LiveScore/Widgets/MatchDayCards.dart';
import 'package:LiveScore/constants.dart';
import 'package:LiveScore/services/FirestoreService.dart';
import 'package:LiveScore/services/HttpService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                    child: PinnedMatchCard(
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
              const MatchDayEmptyCard()
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
                      child: MatchDayCard(
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
