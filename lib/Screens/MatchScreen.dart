import 'package:flutter/material.dart';
import 'package:LiveScore/Widgets/MatchDetailsCards.dart';
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
                  MatchResultCard(
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                    score: score,
                    halfTime: halfTime,
                  ),
                  const SizedBox(height: 16),
                  MatchInfoCard(title: 'Match Date', value: formattedDate),
                  MatchInfoCard(
                    title: 'Matchday',
                    value: matchData['matchday'].toString(),
                  ),
                  MatchInfoCard(
                      title: 'Competition', value: competition['name']),
                  MatchInfoCard(title: 'Area', value: area['name']),
                  MatchInfoCard(
                      title: 'Match Status', value: matchData['status']),
                  const SizedBox(height: 16),
                  MatchInfoCard(
                    title: 'Referee',
                    value: referees != null && referees.isNotEmpty
                        ? referees[0]['name']
                        : 'N/A',
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
