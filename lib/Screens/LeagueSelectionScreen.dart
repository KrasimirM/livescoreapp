import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'TeamSelectionScreen.dart';

class LeagueSelectionScreen extends StatefulWidget {
  @override
  _LeagueSelectionScreenState createState() => _LeagueSelectionScreenState();
}

class _LeagueSelectionScreenState extends State<LeagueSelectionScreen> {
  List _leagues = [];

  @override
  void initState() {
    super.initState();
    getLeagues();
  }

  getLeagues() async {
    http.Response response = await http.get(
        Uri.parse('http://api.football-data.org/v4/competitions'),
        headers: {'X-Auth-Token': '27f54ff1ab4b4d2cbbb3d0c34084d70a'});
    String body = response.body;
    Map data = jsonDecode(body);
    setState(() {
      _leagues = data['competitions'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Select League'),
      ),
      body: _leagues.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _leagues.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_leagues[index]['name']),
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
    );
  }
}
