import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../Widgets/QuestionCard.dart';
import '../Models/Question.dart';
import '../Models/QuizCategory.dart';
import 'package:LiveScore/services/FirestoreService.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _quizTitleController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  List<Question> _questions = List.generate(10, (index) => Question());
  String _selectedCategory = QuizCategory.history;
  bool _isSaving = false;
  bool _isSeeding = false;

  void _submitQuiz() async {
    if (_isSaving) return;

    bool hasEmptyFields = _quizTitleController.text.trim().isEmpty ||
        _questions.any((q) =>
            q.question.trim().isEmpty ||
            q.answers.any((a) => a.trim().isEmpty));

    if (hasEmptyFields) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final quizData = {
      'title': _quizTitleController.text.trim(),
      'category': _selectedCategory,
      'questions': _questions
          .map((q) => {
                'question': q.question,
                'answers': q.answers,
                'correctAnswerIndex': q.correctAnswerIndex
              })
          .toList(),
    };

    print('Quiz Data: $quizData');

    // Save to Firestore
    setState(() => _isSaving = true);
    await _firestoreService.saveQuiz(quizData);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Quiz saved to database')));

    // Clear all fields
    _quizTitleController.clear();
    setState(() {
      _questions = List.generate(10, (index) => Question());
      _selectedCategory = QuizCategory.history;
      _isSaving = false;
    });
  }

  Future<void> _seedSampleQuizzes() async {
    if (_isSeeding) return;

    setState(() => _isSeeding = true);
    final inserted = await _firestoreService.seedSampleQuizzes();
    if (!mounted) return;

    setState(() => _isSeeding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Seed complete. Inserted $inserted quizzes.')),
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Panel'),
          backgroundColor: AppColors.primaryColor,
          actions: [
            IconButton(icon: Icon(Icons.logout), onPressed: _signOut),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Quiz',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor)),
              SizedBox(height: 16),
              Text(
                'Category',
                style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: AppColors.cardBackgroundColor,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardBackgroundColor,
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: AppColors.textColor),
                items: QuizCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(QuizCategory.label(category)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedCategory = value);
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _quizTitleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Quiz Title',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ..._questions.asMap().entries.map((entry) {
                int index = entry.key;
                Question q = entry.value;
                return QuestionCard(
                  question: q,
                  questionIndex: index + 1,
                );
              }),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _submitQuiz,
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: AppColors.primaryColor),
                child: Text(
                  _isSaving ? 'Saving...' : 'Submit Quiz',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isSeeding ? null : _seedSampleQuizzes,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  side: BorderSide(color: AppColors.accentColor),
                ),
                child: Text(
                  _isSeeding ? 'Seeding...' : 'Seed Sample Quizzes',
                  style: TextStyle(color: AppColors.accentColor, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
