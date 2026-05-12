import 'package:LiveScore/services/HttpService.dart';
import 'package:flutter/material.dart';
import 'TeamSelectionScreen.dart';
import 'package:LiveScore/constants.dart';
import 'package:LiveScore/Widgets/LoadingView.dart';

class LeagueSelectionScreen extends StatefulWidget {
  @override
  _LeagueSelectionScreenState createState() => _LeagueSelectionScreenState();
}

class _LeagueSelectionScreenState extends State<LeagueSelectionScreen> {
  List _leagues = [];
  bool _isLoading = true;
  String? _errorMessage;
  final HttpService _httpService = HttpService();

  @override
  void initState() {
    super.initState();
    getLeagues();
  }

  void getLeagues() async {
    try {
      final leagues = await _httpService.fetchLeagues();
      setState(() {
        _leagues = leagues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load leagues.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select League'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Container(
        color: AppColors.backgroundColor,
        child: _isLoading
            ? LoadingView(message: 'Loading leagues...')
            : _errorMessage != null
                ? _buildMessage(_errorMessage!, AppColors.errorColor)
                : _leagues.isEmpty
                    ? _buildMessage(
                        'No leagues available.', AppColors.textColor)
                    : ListView.builder(
                        itemCount: _leagues.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _leagues[index]['name'],
                              style: TextStyle(color: AppColors.textColor),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeamSelectionScreen(
                                    leagueCode: _leagues[index]['code'],
                                    leagueName: _leagues[index]['name'],
                                  ),
                                ),
                              ).then((selectedTeam) {
                                if (selectedTeam != null) {
                                  Navigator.pop(context, selectedTeam);
                                }
                              });
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
