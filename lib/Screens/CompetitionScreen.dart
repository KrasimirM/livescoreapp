import 'package:flutter/material.dart';
import 'package:LiveScore/Screens/TableScreen.dart';
import 'package:LiveScore/Widgets/LeagueContainer.dart';

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
                GestureDetector(
                  child: LeagueContainer(
                    image: 'assets/ucl.png',
                    key: GlobalKey(),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TableScreen(
                              code: 'CL',
                              key: GlobalKey(),
                              name: 'UEFA Champions League'),
                        ));
                  },
                ),
                GestureDetector(
                  child:
                      LeagueContainer(image: 'assets/pl.png', key: GlobalKey()),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TableScreen(
                              code: 'PL',
                              key: GlobalKey(),
                              name: 'Premier League'),
                        ));
                  },
                ),
                GestureDetector(
                  child: LeagueContainer(
                    image: 'assets/laliga.png',
                    key: GlobalKey(),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TableScreen(
                              code: 'PD', key: GlobalKey(), name: 'LaLiga'),
                        ));
                  },
                ),
                GestureDetector(
                  child: LeagueContainer(
                    image: 'assets/bundesliga.png',
                    key: GlobalKey(),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TableScreen(
                              code: 'BL1',
                              key: GlobalKey(),
                              name: 'Bundesliga'),
                        ));
                  },
                ),
                GestureDetector(
                  child: LeagueContainer(
                      image: 'assets/seria.png', key: GlobalKey()),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TableScreen(
                              code: 'SA', key: GlobalKey(), name: 'Seria A'),
                        ));
                  },
                ),
                GestureDetector(
                  child: LeagueContainer(
                    image: 'assets/ligue1.png',
                    key: GlobalKey(),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TableScreen(
                              code: 'FL1', key: GlobalKey(), name: 'Ligue1'),
                        ));
                  },
                ),
                GestureDetector(
                  child: LeagueContainer(
                    image: 'assets/nos.png',
                    key: GlobalKey(),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TableScreen(
                              code: 'PPL', key: GlobalKey(), name: 'Liga nos'),
                        ));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
