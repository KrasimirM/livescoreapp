import 'package:flutter/material.dart';
import 'package:LiveScore/constants.dart';
import 'package:LiveScore/services/HttpService.dart';

class UpcomingMatchScreen extends StatefulWidget {
  final Map match;

  const UpcomingMatchScreen({required this.match});

  @override
  _UpcomingMatchScreenState createState() => _UpcomingMatchScreenState();
}

class _UpcomingMatchScreenState extends State<UpcomingMatchScreen> {
  final HttpService _httpService = HttpService();
  Map<String, dynamic>? stats;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    try {
      final data = await _httpService.fetchHeadToHead(
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

  @override
  Widget build(BuildContext context) {
    final homeTeam = widget.match['homeTeam'];
    final awayTeam = widget.match['awayTeam'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Match'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _TeamBadge(team: homeTeam),
                      Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      _TeamBadge(team: awayTeam),
                    ],
                  ),
                  SizedBox(height: 24),
                  if (stats != null && stats!.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          'Predicted Chances',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        _ChanceTile(
                          label: '${stats!['homeTeam']['name']} Win',
                          chance: stats!['homeTeam']['chance'],
                          color: AppColors.primaryColor,
                        ),
                        _ChanceTile(
                          label: 'Draw',
                          chance: stats!['draw'],
                          color: AppColors.subtitleTextColor,
                        ),
                        _ChanceTile(
                          label: '${stats!['awayTeam']['name']} Win',
                          chance: stats!['awayTeam']['chance'],
                          color: AppColors.accentColor,
                        ),
                      ],
                    )
                  else
                    Text(
                      'No stats available',
                      style: TextStyle(color: AppColors.textColor),
                    ),
                ],
              ),
            ),
    );
  }
}

class _TeamBadge extends StatelessWidget {
  final Map team;

  const _TeamBadge({required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(
          team['crest'] ?? '',
          width: 60,
          height: 60,
        ),
        SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            team['name'] ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _ChanceTile extends StatelessWidget {
  final String label;
  final String chance;
  final Color color;

  const _ChanceTile(
      {required this.label, required this.chance, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackgroundColor,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          '$label: $chance%',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
