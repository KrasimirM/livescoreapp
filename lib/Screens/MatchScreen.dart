import 'package:flutter/material.dart';
import 'package:LiveScore/services/HttpService.dart';
import 'package:LiveScore/constants.dart';
import 'package:intl/intl.dart';

class MatchScreen extends StatefulWidget {
  final String matchId;

  const MatchScreen({required this.matchId});

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late Future<Map<String, dynamic>> matchDetails;
  final HttpService _httpService = HttpService();
  Map<String, dynamic>? headToHeadStats;
  bool loadingH2H = false;

  @override
  void initState() {
    super.initState();
    matchDetails = _httpService.fetchMatchDetails(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Details'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: matchDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No match details available.'));
          } else {
            final matchData = snapshot.data!;
            final homeTeam = matchData['homeTeam'];
            final awayTeam = matchData['awayTeam'];
            final score = matchData['score']?['fullTime'];
            final halfTime = matchData['score']?['halfTime'];
            final competition = matchData['competition'];
            final area = matchData['area'];
            final referees = matchData['referees'];
            DateTime matchDate = DateTime.parse(matchData['utcDate']);
            String formattedDate =
                DateFormat('d MMM, yyyy – H:mm').format(matchDate);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MatchResultCard(homeTeam, awayTeam, score, halfTime),
                  SizedBox(height: 16),
                  _InfoCard('Match Date', formattedDate),
                  _InfoCard('Matchday', matchData['matchday'].toString()),
                  _InfoCard('Competition', competition['name']),
                  _InfoCard('Area', area['name']),
                  _InfoCard('Match Status', matchData['status']),
                  SizedBox(height: 16),
                  _InfoCard(
                      'Referee',
                      referees != null && referees.isNotEmpty
                          ? referees[0]['name']
                          : 'N/A'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class _MatchResultCard extends StatelessWidget {
  final homeTeam;
  final awayTeam;
  final score;
  final halfTime;

  const _MatchResultCard(
      this.homeTeam, this.awayTeam, this.score, this.halfTime);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackgroundColor,
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TeamBadge(team: homeTeam),
            _ScoreCard(score, halfTime),
            _TeamBadge(team: awayTeam),
          ],
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            team['crest'],
            width: 60,
            height: 60,
          ),
          SizedBox(height: 8),
          Text(
            team['name'],
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

class _ScoreCard extends StatelessWidget {
  final score;
  final halfTime;

  const _ScoreCard(this.score, this.halfTime);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${score['home']} - ${score['away']}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'HT: ${halfTime['home']} - ${halfTime['away']}',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackgroundColor,
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          '$title: $value',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
