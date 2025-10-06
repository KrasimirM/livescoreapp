import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../services/FirestoreService.dart';
import '../Screens/QuizPlayScreen.dart';
import '../Widgets/QuizCard.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.accentColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Quizzes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List>(
                  future: _firestoreService.fetchQuizzes(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    final quizzes = snapshot.data!;
                    if (quizzes.isEmpty) {
                      return Center(
                        child: Text(
                          'No quizzes available',
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0), // Added vertical padding
                          child: FutureBuilder<Map<String, dynamic>?>(
                            future: _firestoreService.getQuizResultForUser(
                                _userId, quiz.id),
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
                                        );
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
          ),
        ),
      ),
    );
  }
}
