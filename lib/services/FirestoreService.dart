import 'package:cloud_firestore/cloud_firestore.dart';

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
        'questions': quizData['questions'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Quiz saved successfully');
    } catch (e) {
      print('Error saving quiz: $e');
    }
  }

  Future<List<QueryDocumentSnapshot>> fetchQuizzes() async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .orderBy('createdAt', descending: true)
          .get();

      print(snapshot.docs);

      return snapshot.docs;
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
      String userId, String quizId, int score, int totalQuestions) async {
    try {
      await _firestore.collection('quizResults').add({
        'userId': userId,
        'quizId': quizId,
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
}
