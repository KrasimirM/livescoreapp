import 'package:flutter/material.dart';
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: answered
                ? [Colors.grey.shade800, Colors.grey.shade900]
                : [AppColors.primaryColor, AppColors.accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quiz['title'],
                style: TextStyle(
                  color: answered ? Colors.white70 : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              if (answered) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: $scoreText',
                      style: TextStyle(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Answered: $dateText',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
              if (!answered)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Play',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
