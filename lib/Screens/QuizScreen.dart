import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Widgets/QuizListTab.dart';
import '../Widgets/QuizRankingTab.dart';
import '../constants.dart';
import '../services/FirestoreService.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                AppColors.accentColor.withAlpha(70),
                AppColors.backgroundColor,
                const Color(0xFF090C10),
              ],
              center: Alignment.topRight,
              radius: 1.15,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackgroundColor.withAlpha(230),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha(18)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.accentColor.withAlpha(35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.accentColor.withAlpha(120),
                            ),
                          ),
                          child: const Icon(
                            Icons.psychology_alt,
                            color: AppColors.accentColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quiz Arena',
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Play, compare scores and climb the ranking',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.subtitleTextColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor.withAlpha(230),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha(16)),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.secondaryAccentColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.backgroundColor,
                    unselectedLabelColor: AppColors.subtitleTextColor,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.sports_esports),
                        text: 'Play',
                      ),
                      Tab(
                        icon: Icon(Icons.leaderboard),
                        text: 'Ranking',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: [
                      QuizListTab(
                        firestoreService: _firestoreService,
                        userId: _userId,
                      ),
                      QuizRankingTab(
                        firestoreService: _firestoreService,
                        userId: _userId,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
