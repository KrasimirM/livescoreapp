import 'package:flutter/material.dart';
import 'package:LiveScore/Widgets/CrestImage.dart';
import 'package:LiveScore/constants.dart';

class MatchResultCard extends StatelessWidget {
  final dynamic homeTeam;
  final dynamic awayTeam;
  final dynamic score;
  final dynamic halfTime;

  const MatchResultCard({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.score,
    required this.halfTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackgroundColor,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MatchDetailsTeamBadge(team: homeTeam),
            ScoreCard(score: score, halfTime: halfTime),
            MatchDetailsTeamBadge(team: awayTeam),
          ],
        ),
      ),
    );
  }
}

class MatchDetailsTeamBadge extends StatelessWidget {
  final dynamic team;

  const MatchDetailsTeamBadge({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CrestImage(
            crestUrl: team['crest'],
            width: 60,
            height: 60,
          ),
          const SizedBox(height: 8),
          Text(
            team['name'],
            style: const TextStyle(
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

class ScoreCard extends StatelessWidget {
  final dynamic score;
  final dynamic halfTime;

  const ScoreCard({
    super.key,
    required this.score,
    required this.halfTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${score['home']} - ${score['away']}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'HT: ${halfTime['home']} - ${halfTime['away']}',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}

class MatchInfoCard extends StatelessWidget {
  final String title;
  final String value;

  const MatchInfoCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackgroundColor,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          '$title: $value',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
