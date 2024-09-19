import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    getTeams();
  }

  getTeams() async {
    http.Response response = await http.get(
        Uri.parse(
            'http://api.football-data.org/v4/competitions/${widget.leagueCode}/teams'),
        headers: {'X-Auth-Token': '27f54ff1ab4b4d2cbbb3d0c34084d70a'});
    String body = response.body;
    Map data = jsonDecode(body);
    setState(() {
      _teams = data['teams'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Select Team'),
      ),
      body: _teams.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _teams.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_teams[index]['name']),
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
    );
  }
}
