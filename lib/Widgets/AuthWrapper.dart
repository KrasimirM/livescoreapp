import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Screens/HomeScreen.dart';
import '../Screens/LoginScreen.dart';
import '../Screens/AdminScreen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData) {
          return LoginScreen();
        }

        final user = snapshot.data!;
        // Use FutureBuilder to fetch Firestore document
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return LoginScreen();
            }

            final userData = userSnapshot.data!.data()!;
            final isAdmin = userData['is_admin'] ?? false;

            if (isAdmin) {
              print('Admin user detected!');
              return AdminScreen();
            }

            print('Regular user detected!');
            return HomeScreen();
          },
        );
      },
    );
  }
}
