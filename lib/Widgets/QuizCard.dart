import 'package:flutter/material.dart';
import '../Models/QuizCategory.dart';
import '../constants.dart';
import 'package:intl/intl.dart';

class QuizCardWidget extends StatelessWidget {
  final dynamic quiz;
  final bool answered;
  final Map<String, dynamic>? result;
  final VoidCallback? onTap;

  const QuizCardWidget({
    required this.quiz,
    required this.answered,
    this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String scoreText = '';
    String tag = '';
    String dateText = '';
    final quizData = quiz.data() as Map<String, dynamic>;
    final category = quizData['category'] ?? QuizCategory.history;

    if (answered && result != null) {
      int score = result!['score'] ?? 0;
      int totalQuestions = result!['totalQuestions'] ?? 10;
      double percent = (score / totalQuestions) * 100;

      if (percent < 50) {
        tag = 'Bad';
      } else if (percent < 70) {
        tag = 'Good';
      } else if (percent < 90) {
        tag = 'Great';
      } else {
        tag = 'Excellent';
      }

      scoreText = '$score/$totalQuestions';
      DateTime answeredAt = result!['answeredAt'].toDate();
      dateText = DateFormat('dd MMM yyyy – HH:mm').format(answeredAt);
    }

    final questions = (quizData['questions'] as List?)?.length ?? 0;
    final cardAccent =
        answered ? AppColors.mutedTextColor : AppColors.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundColor.withAlpha(235),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: answered
                ? Colors.white.withAlpha(16)
                : AppColors.accentColor.withAlpha(95),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(55),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cardAccent.withAlpha(35),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: cardAccent.withAlpha(120)),
                  ),
                  child: Icon(
                    answered ? Icons.check_circle : Icons.bolt,
                    color: cardAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    quiz['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: answered
                          ? AppColors.subtitleTextColor
                          : AppColors.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuizMetaChip(
                  icon: Icons.category,
                  label: QuizCategory.label(category),
                  color: AppColors.primaryColor,
                ),
                _QuizMetaChip(
                  icon: Icons.help_outline,
                  label: '$questions questions',
                  color: AppColors.secondaryAccentColor,
                ),
                if (answered)
                  _QuizMetaChip(
                    icon: Icons.workspace_premium,
                    label: tag,
                    color: AppColors.accentColor,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (answered) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Score $scoreText',
                      style: const TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    dateText,
                    style: const TextStyle(
                      color: AppColors.mutedTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ] else
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Start',
                        style: TextStyle(
                          color: AppColors.backgroundColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.backgroundColor,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuizMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuizMetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.subtitleTextColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
