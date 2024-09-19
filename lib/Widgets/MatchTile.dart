import 'package:flutter/material.dart';

class MatchTile extends StatelessWidget {
  final Map match;

  const MatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.pinkAccent,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
            '${match['homeTeam']['name']} vs ${match['awayTeam']['name']}'),
        subtitle: Text(
            '${match['utcDate'].substring(0, 10)} - ${match['score']['fullTime']['home']} : ${match['score']['fullTime']['away']}'),
      ),
    );
  }
}
