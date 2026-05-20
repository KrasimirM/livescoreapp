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
      bottomNavigationBar: _FloatingBottomNav(
        selectedIndex: _selectedIndex,
        onSelected: _onItemTapped,
      ),
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FloatingBottomNav({
    required this.selectedIndex,
    required this.onSelected,
  });

  static const items = [
    _NavItem(Icons.emoji_events_outlined, Icons.emoji_events, 'Hub'),
    _NavItem(Icons.star_border, Icons.star, 'Team'),
    _NavItem(Icons.psychology_alt_outlined, Icons.psychology_alt, 'Quiz'),
    _NavItem(Icons.person_outline, Icons.person, 'Me'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        height: 64,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor.withAlpha(244),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withAlpha(18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(95),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = selectedIndex == index;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _BottomNavButton(
                  item: item,
                  selected: selected,
                  onTap: () => onSelected(index),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}

class _BottomNavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: double.infinity,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor.withAlpha(44)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? AppColors.primaryColor.withAlpha(115)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.selectedIcon : item.icon,
              color:
                  selected ? AppColors.primaryColor : AppColors.mutedTextColor,
              size: 21,
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                style: TextStyle(
                  color:
                      selected ? AppColors.textColor : AppColors.mutedTextColor,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
