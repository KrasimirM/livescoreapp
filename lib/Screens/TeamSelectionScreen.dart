import 'package:flutter/material.dart';
import 'package:LiveScore/services/HttpService.dart';
import 'package:LiveScore/constants.dart';
import 'package:LiveScore/Widgets/LoadingView.dart';

class TeamSelectionScreen extends StatefulWidget {
  final String leagueCode;
  final String leagueName;

  const TeamSelectionScreen(
      {required this.leagueCode, required this.leagueName});

  @override
  _TeamSelectionScreenState createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  List _teams = [];
  bool _isLoading = true;
  String? _errorMessage;
  final HttpService _httpService = HttpService();

  @override
  void initState() {
    super.initState();
    getTeams();
  }

  getTeams() async {
    try {
      final teams = await _httpService.fetchTeams(widget.leagueCode);
      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load teams.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Team'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Container(
        color: AppColors.backgroundColor, // Setting background color
        child: _isLoading
            ? LoadingView(message: 'Loading teams...')
            : _errorMessage != null
                ? _buildMessage(_errorMessage!, AppColors.errorColor)
                : _teams.isEmpty
                    ? _buildMessage('No teams available.', AppColors.textColor)
                    : ListView.builder(
                        itemCount: _teams.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _teams[index]['name'],
                              style: TextStyle(color: AppColors.textColor),
                            ),
                            onTap: () {
                              final selectedTeam = {
                                'name': _teams[index]['name'],
                                'id': _teams[index]['id'].toString(),
                                'crest': _teams[index]['crest'],
                              };
                              Navigator.pop(context, selectedTeam);
                            },
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildMessage(String message, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: TextStyle(color: color, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
