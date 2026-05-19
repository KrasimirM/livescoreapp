import 'package:flutter/material.dart';
import 'CompetitionScreen.dart';
import 'FavouriteTeamScreen.dart';
import 'Profile_screen.dart';
import 'QuizScreen.dart';
import 'package:LiveScore/constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _teamRefreshToken = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _refreshFavoriteTeam() {
    setState(() {
      _teamRefreshToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      CompetitionsScreen(),
      Favouriteteamscreen(
        refreshToken: _teamRefreshToken,
        onFavoriteTeamChanged: _refreshFavoriteTeam,
      ),
      QuizScreen(),
      ProfileScreen(
        refreshToken: _teamRefreshToken,
        onNavigate: _onItemTapped,
        onFavoriteTeamChanged: _refreshFavoriteTeam,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              AppColors.primaryColor.withAlpha(70),
              AppColors.backgroundColor,
              Color(0xFF090C10),
            ],
            center: Alignment.topLeft,
            radius: 1.25,
            stops: [0.0, 0.46, 1.0],
          ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor.withAlpha(242),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withAlpha(18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(90),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: NavigationBar(
            height: 66,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppColors.primaryColor.withAlpha(45),
            selectedIndex: _selectedIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: _onItemTapped,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events),
                label: 'Leagues',
              ),
              NavigationDestination(
                icon: Icon(Icons.star_border),
                selectedIcon: Icon(Icons.star),
                label: 'Team',
              ),
              NavigationDestination(
                icon: Icon(Icons.psychology_alt_outlined),
                selectedIcon: Icon(Icons.psychology_alt),
                label: 'Quiz',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
