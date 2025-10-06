import 'package:LiveScore/Widgets/MatchTile.dart';
import 'package:flutter/material.dart';

class MatchSection extends StatelessWidget {
  final String sectionTitle;
  final List matches;

  const MatchSection({
    required this.sectionTitle,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          sectionTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            return MatchTile(match: matches[index]);
          },
        ),
      ],
    );
  }
}
