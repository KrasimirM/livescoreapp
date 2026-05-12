import 'package:flutter/material.dart';
import '../Models/QuizCategory.dart';
import '../Screens/QuizPlayScreen.dart';
import '../services/FirestoreService.dart';
import 'LoadingView.dart';
import 'QuizCard.dart';
import 'QuizCategoryFilter.dart';

class QuizListTab extends StatefulWidget {
  final FirestoreService firestoreService;
  final String userId;

  const QuizListTab({
    Key? key,
    required this.firestoreService,
    required this.userId,
  }) : super(key: key);

  @override
  State<QuizListTab> createState() => _QuizListTabState();
}

class _QuizListTabState extends State<QuizListTab> {
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
          child: FutureBuilder<List>(
            future: widget.firestoreService.fetchQuizzes(
              category: _selectedCategory,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingView(message: 'Loading quizzes...');
              }

              final quizzes = snapshot.data!;
              if (quizzes.isEmpty) {
                return Center(
                  child: Text(
                    'No quizzes in this category',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: widget.firestoreService.getQuizResultForUser(
                        widget.userId,
                        quiz.id,
                      ),
                      builder: (context, resultSnapshot) {
                        final result = resultSnapshot.data;
                        bool answered = result != null;

                        return QuizCardWidget(
                          quiz: quiz,
                          answered: answered,
                          result: result,
                          onTap: answered
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuizPlayScreen(
                                        quizId: quiz.id,
                                        quizData: quiz.data(),
                                      ),
                                    ),
                                  ).then((_) => setState(() {}));
                                },
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
