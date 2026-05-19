import 'package:flutter/material.dart';
import 'package:LiveScore/Widgets/CrestImage.dart';

class TeamInfo extends StatelessWidget {
  final String teamName;
  final String crestUrl;

  const TeamInfo({
    required this.teamName,
    required this.crestUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CrestImage(
          crestUrl: crestUrl,
          width: 100,
          height: 100,
        ),
        SizedBox(height: 10),
        Text(
          teamName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
