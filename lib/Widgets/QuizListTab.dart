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
        const SizedBox(height: 12),
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
                return const _QuizEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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

class _QuizEmptyState extends StatelessWidget {
  const _QuizEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF151B23).withAlpha(230),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(16)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.quiz_outlined,
              color: Color(0xFFFFB02E),
              size: 36,
            ),
            SizedBox(height: 10),
            Text(
              'No quizzes in this category',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
