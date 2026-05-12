import 'package:flutter/material.dart';
import '../constants.dart';
import '../Models/QuizCategory.dart';
import '../services/FirestoreService.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizPlayScreen extends StatefulWidget {
  final String quizId;
  final Map<String, dynamic> quizData;

  const QuizPlayScreen({required this.quizId, required this.quizData, Key? key})
      : super(key: key);

  @override
  _QuizPlayScreenState createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  int _currentQuestionIndex = 0;
  int _score = 0;
  List<int> _selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(widget.quizData['questions'].length, -1);
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = index;

      if (index ==
          widget.quizData['questions'][_currentQuestionIndex]
              ['correctAnswerIndex']) {
        _score++;
      }

      if (_currentQuestionIndex < widget.quizData['questions'].length - 1) {
        _currentQuestionIndex++;
      } else {
        _finishQuiz();
      }
    });
  }

  void _finishQuiz() async {
    await _firestoreService.saveQuizResult(
      _userId,
      widget.quizId,
      _score,
      widget.quizData['questions'].length,
      category: widget.quizData['category'] ?? QuizCategory.history,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundColor,
        title: Text('Quiz Completed',
            style: TextStyle(color: AppColors.primaryColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You scored $_score / ${widget.quizData['questions'].length}',
              style: TextStyle(color: AppColors.textColor, fontSize: 18),
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: _score / widget.quizData['questions'].length,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: AppColors.accentColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quizData['questions'][_currentQuestionIndex];
    final totalQuestions = widget.quizData['questions'].length;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(widget.quizData['title']),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            Text(
              'Question ${_currentQuestionIndex + 1} of $totalQuestions',
              style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / totalQuestions,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentColor),
              minHeight: 8,
            ),
            SizedBox(height: 24),

            // Question
            Text(
              question['question'],
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            SizedBox(height: 24),

            // Answers
            ...List.generate(4, (i) {
              bool selected = _selectedAnswers[_currentQuestionIndex] == i;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: _selectedAnswers[_currentQuestionIndex] == -1
                      ? () => _selectAnswer(i)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selected ? AppColors.accentColor : Colors.grey.shade800,
                    minimumSize: Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    question['answers'][i],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
