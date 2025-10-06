import 'package:flutter/material.dart';

class TeamHeader extends StatelessWidget {
  final String teamName;
  final String crestUrl;

  const TeamHeader({
    required this.teamName,
    required this.crestUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(crestUrl, height: 100),
        SizedBox(height: 10),
        Text(
          teamName,
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
