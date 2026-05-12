import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/QuizCategory.dart';
import '../data/sample_quizzes.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser(String email) async {
    DocumentReference newUserRef = await _firestore.collection('users').add({
      'email': email,
      'favorite_team': '',
      'favorite_team_id': '',
    });
    print('User created with ID: ${newUserRef.id}');
  }

  Future<Map<String, dynamic>> getUserData(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return snapshot.exists ? snapshot.data()! : {};
  }

  Future<void> updateFavoriteTeam(
      String email, String teamName, String teamId) async {
    QuerySnapshot userSnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      String userId = userSnapshot.docs.first.id;
      await _firestore.collection('users').doc(userId).update({
        'favorite_team': teamName,
        'favorite_team_id': teamId,
      });
    } else {
      print('User not found with email: $email');
    }
  }

  Future<void> saveQuiz(Map<String, dynamic> quizData) async {
    try {
      await _firestore.collection('quizzes').add({
        'title': quizData['title'],
        'category': quizData['category'] ?? QuizCategory.history,
        'questions': quizData['questions'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Quiz saved successfully');
    } catch (e) {
      print('Error saving quiz: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> fetchQuizzes({
    String category = QuizCategory.all,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .orderBy('createdAt', descending: true)
          .get();

      if (category == QuizCategory.all) return snapshot.docs;
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final quizCategory = data['category'] ?? QuizCategory.history;
        return quizCategory == category;
      }).toList();
    } catch (e) {
      print('Error fetching quizzes: $e');
      return [];
    }
  }

  Future<bool> hasUserAnsweredQuiz(String userId, String quizId) async {
    final result = await _firestore
        .collection('quizResults')
        .where('userId', isEqualTo: userId)
        .where('quizId', isEqualTo: quizId)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> saveQuizResult(
    String userId,
    String quizId,
    int score,
    int totalQuestions, {
    String category = QuizCategory.history,
  }) async {
    try {
      final userData = await getUserData(userId);
      await _firestore.collection('quizResults').add({
        'userId': userId,
        'quizId': quizId,
        'email': userData['email'] ?? '',
        'category': category,
        'score': score,
        'totalQuestions': totalQuestions,
        'answeredAt': FieldValue.serverTimestamp(),
      });
      print('Quiz result saved successfully');
    } catch (e) {
      print('Error saving quiz result: $e');
    }
  }

  Future<Map<String, dynamic>?> getQuizResultForUser(
      String userId, String quizId) async {
    final result = await _firestore
        .collection('quizResults')
        .where('userId', isEqualTo: userId)
        .where('quizId', isEqualTo: quizId)
        .get();

    if (result.docs.isNotEmpty) {
      return result.docs.first.data();
    }
    return null;
  }

  Future<Map<String, dynamic>> getUserQuizStats(
    String userId, {
    String category = QuizCategory.all,
  }) async {
    final snapshot = await _firestore
        .collection('quizResults')
        .where('userId', isEqualTo: userId)
        .get();

    int totalScore = 0;
    int totalQuestions = 0;
    int perfectScores = 0;
    final solvedByCategory = <String, int>{
      QuizCategory.history: 0,
      QuizCategory.teams: 0,
      QuizCategory.players: 0,
    };

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (!_matchesCategory(data, category)) continue;

      final resultCategory = data['category'] ?? QuizCategory.history;
      final score = _readInt(data['score']);
      final questions = _readInt(data['totalQuestions']);

      totalScore += score;
      totalQuestions += questions;
      if (solvedByCategory.containsKey(resultCategory)) {
        solvedByCategory[resultCategory] =
            solvedByCategory[resultCategory]! + 1;
      }
      if (questions > 0 && score == questions) {
        perfectScores++;
      }
    }

    final quizzesAnswered = totalQuestions == 0
        ? 0
        : snapshot.docs
            .where((doc) => _matchesCategory(doc.data(), category))
            .length;
    final averagePercent =
        totalQuestions == 0 ? 0.0 : (totalScore / totalQuestions) * 100;

    return {
      'quizzesAnswered': quizzesAnswered,
      'totalScore': totalScore,
      'totalQuestions': totalQuestions,
      'averagePercent': averagePercent,
      'perfectScores': perfectScores,
      'category': category,
      'badge': _badgeForStats(quizzesAnswered, averagePercent, perfectScores),
      'achievements': _achievementsForStats(
        quizzesAnswered,
        averagePercent,
        perfectScores,
        solvedByCategory,
      ),
    };
  }

  Future<List<Map<String, dynamic>>> fetchQuizLeaderboard({
    String category = QuizCategory.all,
  }) async {
    final resultsSnapshot = await _firestore.collection('quizResults').get();
    final usersSnapshot = await _firestore.collection('users').get();

    final emailsByUserId = {
      for (final doc in usersSnapshot.docs)
        doc.id: ((doc.data()['email'] ?? '') as String)
    };
    final statsByUserId = <String, Map<String, dynamic>>{};

    for (final doc in resultsSnapshot.docs) {
      final data = doc.data();
      if (!_matchesCategory(data, category)) continue;

      final userId = (data['userId'] ?? '').toString();
      if (userId.toString().isEmpty) continue;

      final score = _readInt(data['score']);
      final questions = _readInt(data['totalQuestions']);
      final stats = statsByUserId.putIfAbsent(
        userId,
        () => {
          'userId': userId,
          'email': data['email'] ?? emailsByUserId[userId] ?? 'Unknown user',
          'quizzesAnswered': 0,
          'totalScore': 0,
          'totalQuestions': 0,
          'perfectScores': 0,
          'category': category,
        },
      );

      stats['quizzesAnswered'] = stats['quizzesAnswered'] + 1;
      stats['totalScore'] = stats['totalScore'] + score;
      stats['totalQuestions'] = stats['totalQuestions'] + questions;
      if (questions > 0 && score == questions) {
        stats['perfectScores'] = stats['perfectScores'] + 1;
      }
    }

    final leaderboard = statsByUserId.values.map((stats) {
      final totalScore = stats['totalScore'] as int;
      final totalQuestions = stats['totalQuestions'] as int;
      final quizzesAnswered = stats['quizzesAnswered'] as int;
      final perfectScores = stats['perfectScores'] as int;
      final averagePercent =
          totalQuestions == 0 ? 0.0 : (totalScore / totalQuestions) * 100;

      return {
        ...stats,
        'averagePercent': averagePercent,
        'badge': _badgeForStats(quizzesAnswered, averagePercent, perfectScores),
      };
    }).toList();

    leaderboard.sort((a, b) {
      final scoreCompare =
          (b['totalScore'] as int).compareTo(a['totalScore'] as int);
      if (scoreCompare != 0) return scoreCompare;
      return (b['averagePercent'] as double)
          .compareTo(a['averagePercent'] as double);
    });

    return leaderboard;
  }

  Future<int> seedSampleQuizzes() async {
    int inserted = 0;
    for (final quiz in sampleQuizzes) {
      final existing = await _firestore
          .collection('quizzes')
          .where('title', isEqualTo: quiz['title'])
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) continue;

      await _firestore.collection('quizzes').add({
        ...quiz,
        'createdAt': FieldValue.serverTimestamp(),
      });
      inserted++;
    }
    return inserted;
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  bool _matchesCategory(Map<String, dynamic> data, String category) {
    if (category == QuizCategory.all) return true;
    final itemCategory = data['category'] ?? QuizCategory.history;
    return itemCategory == category;
  }

  String _badgeForStats(
      int quizzesAnswered, double averagePercent, int perfectScores) {
    if (perfectScores > 0 || averagePercent >= 95) {
      return 'Perfect Score';
    }
    if (averagePercent >= 75) {
      return 'Football Expert';
    }
    if (quizzesAnswered >= 1) {
      return 'Beginner';
    }
    return 'No Badge';
  }

  List<String> _achievementsForStats(
    int quizzesAnswered,
    double averagePercent,
    int perfectScores,
    Map<String, int> solvedByCategory,
  ) {
    final achievements = <String>[];

    if (quizzesAnswered >= 1) achievements.add('First Quiz Completed');
    if (perfectScores > 0) achievements.add('Perfect Score');
    if (quizzesAnswered >= 5) achievements.add('5 Quizzes Solved');
    if ((solvedByCategory[QuizCategory.history] ?? 0) >= 3) {
      achievements.add('History Specialist');
    }
    if ((solvedByCategory[QuizCategory.players] ?? 0) >= 3) {
      achievements.add('Players Expert');
    }
    if ((solvedByCategory[QuizCategory.teams] ?? 0) >= 3) {
      achievements.add('Teams Expert');
    }
    if (averagePercent >= 85 && quizzesAnswered >= 3) {
      achievements.add('Consistent Performer');
    }

    return achievements;
  }
}
