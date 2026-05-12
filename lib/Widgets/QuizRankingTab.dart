import 'package:flutter/material.dart';
import '../Models/QuizCategory.dart';
import '../constants.dart';
import '../services/FirestoreService.dart';
import 'LoadingView.dart';
import 'QuizCategoryFilter.dart';

class QuizRankingTab extends StatefulWidget {
  final FirestoreService firestoreService;
  final String userId;

  const QuizRankingTab({
    Key? key,
    required this.firestoreService,
    required this.userId,
  }) : super(key: key);

  @override
  State<QuizRankingTab> createState() => _QuizRankingTabState();
}

class _QuizRankingTabState extends State<QuizRankingTab> {
  String _selectedCategory = QuizCategory.all;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuizCategoryFilter(
          selectedCategory: _selectedCategory,
          onChanged: (category) {
            setState(() => _selectedCategory = category);
          },
        ),
        SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: Future.wait([
              widget.firestoreService.getUserQuizStats(
                widget.userId,
                category: _selectedCategory,
              ),
              widget.firestoreService.fetchQuizLeaderboard(
                category: _selectedCategory,
              ),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingView(message: 'Loading ranking...');
              }

              final userStats = snapshot.data![0] as Map<String, dynamic>;
              final leaderboard =
                  snapshot.data![1] as List<Map<String, dynamic>>;

              return ListView(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                children: [
                  _StatsCard(stats: userStats),
                  SizedBox(height: 16),
                  _LeaderboardHeader(category: _selectedCategory),
                  SizedBox(height: 8),
                  if (leaderboard.isEmpty)
                    _EmptyRankingCard()
                  else
                    ...leaderboard.asMap().entries.map(
                          (entry) => _LeaderboardTile(
                            rank: entry.key + 1,
                            user: entry.value,
                            isCurrentUser:
                                entry.value['userId'] == widget.userId,
                          ),
                        ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final totalScore = stats['totalScore'] as int;
    final totalQuestions = stats['totalQuestions'] as int;
    final quizzesAnswered = stats['quizzesAnswered'] as int;
    final averagePercent = stats['averagePercent'] as double;
    final perfectScores = stats['perfectScores'] as int;
    final badge = stats['badge'] as String;
    final achievements = (stats['achievements'] as List).cast<String>();

    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium, color: AppColors.accentColor),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your Quiz Profile',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatPill(label: 'Total', value: '$totalScore/$totalQuestions'),
              _StatPill(label: 'Quizzes', value: '$quizzesAnswered'),
              _StatPill(
                label: 'Average',
                value: '${averagePercent.toStringAsFixed(1)}%',
              ),
              _StatPill(label: 'Perfect', value: '$perfectScores'),
              _StatPill(label: 'Badge', value: badge, wide: true),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Achievements',
            style: TextStyle(
              color: AppColors.subtitleTextColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          if (achievements.isEmpty)
            Text(
              'Complete a quiz to unlock your first achievement.',
              style: TextStyle(color: AppColors.subtitleTextColor),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: achievements
                  .map((achievement) => _AchievementChip(label: achievement))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _AchievementChip extends StatelessWidget {
  final String label;

  const _AchievementChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withAlpha(55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryColor.withAlpha(140)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, color: AppColors.accentColor, size: 16),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final bool wide;

  const _StatPill({
    required this.label,
    required this.value,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? 300 : 145,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.subtitleTextColor, fontSize: 13),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  final String category;

  const _LeaderboardHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${QuizCategory.label(category)} Leaderboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(Icons.leaderboard, color: AppColors.accentColor),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> user;
  final bool isCurrentUser;

  const _LeaderboardTile({
    required this.rank,
    required this.user,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final email = user['email'] as String;
    final totalScore = user['totalScore'] as int;
    final totalQuestions = user['totalQuestions'] as int;
    final averagePercent = user['averagePercent'] as double;
    final badge = user['badge'] as String;
    final quizzesAnswered = user['quizzesAnswered'] as int;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primaryColor.withAlpha(70)
            : AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser ? AppColors.primaryColor : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                rank <= 3 ? AppColors.accentColor : AppColors.primaryColor,
            child: Text(
              '$rank',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email.isEmpty ? 'Unknown user' : email,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '$badge • $quizzesAnswered quizzes • Avg ${averagePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: AppColors.subtitleTextColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text(
            '$totalScore/$totalQuestions',
            style: TextStyle(
              color: AppColors.accentColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRankingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'No quiz results in this category yet.',
        style: TextStyle(color: AppColors.textColor, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
