import 'package:flutter/material.dart';
import 'package:LiveScore/Screens/TableScreen.dart';
import 'package:LiveScore/Widgets/LeagueContainer.dart';

class LeagueCard extends StatelessWidget {
  final String image;
  final String code;
  final String name;

  const LeagueCard({
    Key? key,
    required this.image,
    required this.code,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: LeagueContainer(
        image: image,
        key: GlobalKey(),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TableScreen(
              code: code,
              key: GlobalKey(),
              name: name,
            ),
          ),
        );
      },
    );
  }
}
