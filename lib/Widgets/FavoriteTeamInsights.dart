import 'package:flutter/material.dart';
import '../constants.dart';

class FavoriteTeamInsights extends StatelessWidget {
  final String teamId;
  final List pastMatches;

  const FavoriteTeamInsights({
    Key? key,
    required this.teamId,
    required this.pastMatches,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final insights = _buildInsights();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: AppColors.accentColor),
              SizedBox(width: 8),
              Text(
                'Team Insights',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            'Recent Form',
            style: TextStyle(
              color: AppColors.subtitleTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: insights.form
                .map((result) => _FormBadge(result: result))
                .toList(),
          ),
          SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InsightTile(
                label: 'Avg Goals',
                value: insights.averageGoals.toStringAsFixed(1),
              ),
              _InsightTile(
                label: 'Clean Sheets',
                value: '${insights.cleanSheets}/${insights.matchesCount}',
              ),
              _InsightTile(
                label: 'Unbeaten',
                value: '${insights.unbeatenStreak} matches',
              ),
            ],
          ),
        ],
      ),
    );
  }

  _TeamInsights _buildInsights() {
    final recentMatches = pastMatches.take(5).toList();
    if (recentMatches.isEmpty) {
      return _TeamInsights(
        form: ['-', '-', '-', '-', '-'],
        averageGoals: 0,
        cleanSheets: 0,
        unbeatenStreak: 0,
        matchesCount: 0,
      );
    }

    int goalsFor = 0;
    int cleanSheets = 0;
    int unbeatenStreak = 0;
    bool streakStillActive = true;
    final form = <String>[];

    for (final match in recentMatches) {
      final homeId = match['homeTeam']['id'].toString();
      final homeScore = match['score']['fullTime']['home'] ?? 0;
      final awayScore = match['score']['fullTime']['away'] ?? 0;
      final isHome = homeId == teamId;

      final teamGoals = isHome ? homeScore : awayScore;
      final opponentGoals = isHome ? awayScore : homeScore;

      goalsFor += teamGoals as int;
      if (opponentGoals == 0) cleanSheets++;

      final result = teamGoals > opponentGoals
          ? 'W'
          : teamGoals == opponentGoals
              ? 'D'
              : 'L';
      form.add(result);

      if (streakStillActive && result != 'L') {
        unbeatenStreak++;
      } else {
        streakStillActive = false;
      }
    }

    while (form.length < 5) {
      form.add('-');
    }

    return _TeamInsights(
      form: form,
      averageGoals: goalsFor / recentMatches.length,
      cleanSheets: cleanSheets,
      unbeatenStreak: unbeatenStreak,
      matchesCount: recentMatches.length,
    );
  }
}

class _FormBadge extends StatelessWidget {
  final String result;

  const _FormBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result == 'W'
        ? AppColors.primaryColor
        : result == 'D'
            ? AppColors.accentColor
            : result == 'L'
                ? AppColors.errorColor
                : Colors.white24;

    return Container(
      width: 34,
      height: 34,
      margin: EdgeInsets.only(right: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        result,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String label;
  final String value;

  const _InsightTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 135,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.subtitleTextColor,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamInsights {
  final List<String> form;
  final double averageGoals;
  final int cleanSheets;
  final int unbeatenStreak;
  final int matchesCount;

  const _TeamInsights({
    required this.form,
    required this.averageGoals,
    required this.cleanSheets,
    required this.unbeatenStreak,
    required this.matchesCount,
  });
}
