import 'package:LiveScore/Screens/MatchScreen.dart';
import 'package:flutter/material.dart';
import 'package:LiveScore/constants.dart';

class MatchTile extends StatelessWidget {
  final Map match;

  const MatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    bool isUpcoming = match['score']['fullTime']['home'] == null;

    return Card(
      color: AppColors.cardBackgroundColor,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TeamBadge(team: match['homeTeam']),
            isUpcoming
                ? Text(
                    'Upcoming',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  )
                : Text(
                    '${match['score']['fullTime']['home']} - ${match['score']['fullTime']['away']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            _TeamBadge(team: match['awayTeam']),
          ],
        ),
        onTap: () {
          if (!isUpcoming) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MatchScreen(matchId: match['id'].toString()),
              ),
            );
          }
        },
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
          Image.network(
            team['crest'] ?? '',
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
