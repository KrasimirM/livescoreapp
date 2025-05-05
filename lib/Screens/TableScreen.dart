import 'dart:convert';
import 'package:LiveScore/services/HttpService.dart';
import 'package:flutter/material.dart';
import 'package:LiveScore/constants.dart';

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
  final HttpService _httpService = HttpService();

  @override
  void initState() {
    getTable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: _table.isEmpty
          ? Container(
              color: AppColors.backgroundColor,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentColor),
                ),
              ),
            )
          : Container(
              color: AppColors.backgroundColor,
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Club',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              Text(
                                'W',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              Text(
                                'D',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              Text(
                                'L',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              Text(
                                'GD',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              Text(
                                'Pts',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
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
    try {
      final table = await _httpService.fetchTable(widget.code);
      setState(() {
        _table = table;
      });
    } catch (e) {
      print('Error fetching table: $e');
    }
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
                        ? Text(
                            team['position'].toString() + ' - ',
                            style: TextStyle(color: AppColors.textColor),
                          )
                        : Text(
                            " " + team['position'].toString() + ' - ',
                            style: TextStyle(color: AppColors.textColor),
                          ),
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
                            ? Text(
                                team['team']['shortName']
                                        .toString()
                                        .substring(0, 11) +
                                    '...',
                                style: TextStyle(color: AppColors.textColor),
                              )
                            : Text(
                                team['team']['shortName'].toString(),
                                style: TextStyle(color: AppColors.textColor),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      team['playedGames'].toString(),
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    Text(
                      team['won'].toString(),
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    Text(
                      team['draw'].toString(),
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    Text(
                      team['lost'].toString(),
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    Text(
                      team['goalDifference'].toString(),
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    Text(
                      team['points'].toString(),
                      style: TextStyle(color: AppColors.textColor),
                    ),
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
