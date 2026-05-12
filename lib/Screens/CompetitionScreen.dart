import 'package:flutter/material.dart';
import 'package:LiveScore/Widgets/LeagueCard.dart';
import 'package:LiveScore/constants.dart';

class CompetitionsScreen extends StatelessWidget {
  final List<LeagueCard> _leagues = const [
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
  ];

  CompetitionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Text(
                  'Competitions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _leagues[index],
                  childCount: _leagues.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
