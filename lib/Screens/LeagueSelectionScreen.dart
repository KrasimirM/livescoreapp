import 'dart:convert';
import 'package:LiveScore/services/HttpService.dart';
import 'package:flutter/material.dart';
import 'TeamSelectionScreen.dart';
import 'package:LiveScore/constants.dart';

class LeagueSelectionScreen extends StatefulWidget {
  @override
  _LeagueSelectionScreenState createState() => _LeagueSelectionScreenState();
}

class _LeagueSelectionScreenState extends State<LeagueSelectionScreen> {
  List _leagues = [];
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
      });
    } catch (e) {
      print('Error fetching leagues: $e');
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
        child: _leagues.isEmpty
            ? Center(child: CircularProgressIndicator())
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
}
