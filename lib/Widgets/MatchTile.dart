// widgets/match_tile.dart
import 'package:flutter/material.dart';
import 'package:LiveScore/constants.dart';
import 'package:LiveScore/Screens/MatchScreen.dart';
import 'package:LiveScore/Screens/UpcomingMatchScreen.dart';
import 'package:LiveScore/Widgets/CrestImage.dart';

class MatchTile extends StatelessWidget {
  final Map match;

  const MatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    bool isUpcoming = match['score']['fullTime']['home'] == null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(235),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(45),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isUpcoming) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpcomingMatchScreen(match: match),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MatchScreen(matchId: match['id'].toString()),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TeamBadge(team: match['homeTeam']),
              isUpcoming
                  ? const _UpcomingActionPill()
                  : _ScorePill(match: match),
              _TeamBadge(team: match['awayTeam']),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingActionPill extends StatelessWidget {
  const _UpcomingActionPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentColor, AppColors.primaryColor],
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insights,
            color: AppColors.backgroundColor,
            size: 18,
          ),
          SizedBox(height: 3),
          Text(
            'Preview',
            style: TextStyle(
              color: AppColors.backgroundColor,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final Map match;

  const _ScorePill({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.primaryColor.withAlpha(80)),
      ),
      child: Text(
        '${match['score']['fullTime']['home']} - ${match['score']['fullTime']['away']}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.textColor,
        ),
      ),
    );
  }
}

class _TeamBadge extends StatelessWidget {
  final team;

  const _TeamBadge({required this.team});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CrestImage(
            crestUrl: team['crest'],
            width: 50,
            height: 50,
          ),
          SizedBox(height: 8),
          Text(
            team['name'] ?? 'No Team Info',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
