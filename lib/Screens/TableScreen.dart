import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class TableScreen extends StatefulWidget {
  final String code;
  final String name;
  const TableScreen({required Key key, required this.code, required this.name})
      : super(key: key);
  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List _table = [];

  @override
  void initState() {
    getTable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(widget.name),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blue,
      ),
      body: _table == []
          ? Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFe70066),
                  ),
                ),
              ),
            )
          : Container(
              child: ListView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Pos',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Club',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PL',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'W',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'D',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'L',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'GD',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Pts',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  buildTable(),
                ],
              ),
            ),
    );
  }

  getTable() async {
    http.Response response = await http.get(
        Uri.parse(
            'http://api.football-data.org/v4/competitions/${widget.code}/standings'),
        headers: {'X-Auth-Token': '27f54ff1ab4b4d2cbbb3d0c34084d70a'});
    String body = response.body;
    Map data = jsonDecode(body);
    List table = data['standings'][0]['table'];
    setState(() {
      _table = table;
    });
  }

  Widget buildTable() {
    List<Widget> teams = [];
    for (var team in _table) {
      teams.add(
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    team['position'].toString().length > 1
                        ? Text(team['position'].toString() + ' - ')
                        : Text(" " + team['position'].toString() + ' - '),
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          padding: EdgeInsets.only(right: 5),
                          child: Image.network(
                            team['team']['crest'],
                          ),
                        ),
                        team['team']['shortName'].toString().length > 11
                            ? Text(team['team']['shortName']
                                    .toString()
                                    .substring(0, 11) +
                                '...')
                            : Text(team['team']['shortName'].toString()),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(team['playedGames'].toString()),
                    Text(team['won'].toString()),
                    Text(team['draw'].toString()),
                    Text(team['lost'].toString()),
                    Text(team['goalDifference'].toString()),
                    Text(team['points'].toString()),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: teams,
    );
  }
}
