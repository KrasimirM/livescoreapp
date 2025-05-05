import 'package:flutter/material.dart';
import 'package:LiveScore/Widgets/LeagueCard.dart'; // Import the new widget

class CompetitionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'Competitions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                LeagueCard(
                  image: 'assets/ucl.png',
                  code: 'CL',
                  name: 'UEFA Champions League',
                ),
                LeagueCard(
                  image: 'assets/pl.png',
                  code: 'PL',
                  name: 'Premier League',
                ),
                LeagueCard(
                  image: 'assets/laliga.png',
                  code: 'PD',
                  name: 'LaLiga',
                ),
                LeagueCard(
                  image: 'assets/bundesliga.png',
                  code: 'BL1',
                  name: 'Bundesliga',
                ),
                LeagueCard(
                  image: 'assets/seria.png',
                  code: 'SA',
                  name: 'Seria A',
                ),
                LeagueCard(
                  image: 'assets/ligue1.png',
                  code: 'FL1',
                  name: 'Ligue1',
                ),
                LeagueCard(
                  image: 'assets/nos.png',
                  code: 'PPL',
                  name: 'Liga nos',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
