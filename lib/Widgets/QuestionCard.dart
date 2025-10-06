import 'package:flutter/material.dart';
import '../constants.dart';
import '../Models/Question.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final int questionIndex;

  const QuestionCard({
    required this.question,
    required this.questionIndex,
    Key? key,
  }) : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackgroundColor,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${widget.questionIndex}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor)),
            SizedBox(height: 8),
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Question',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  widget.question.question = value;
                });
              },
            ),
            SizedBox(height: 8),
            ...List.generate(4, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: widget.question.correctAnswerIndex,
                      onChanged: (value) {
                        setState(() {
                          widget.question.correctAnswerIndex = value!;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Answer ${i + 1}',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            widget.question.answers[i] = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
