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
}
