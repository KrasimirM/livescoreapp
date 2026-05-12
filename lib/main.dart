import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/HomeScreen.dart';
import 'Screens/AdminScreen.dart';
import 'Screens/ForgotPasswordScreen.dart';
import 'constants.dart';
import 'Widgets/LoadingView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await NotificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LiveScore App',
      theme: _buildTheme(),
      home: AuthGate(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/admin': (context) => AdminScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      appBarTheme: AppBarTheme(
        color: AppColors.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: AppColors.textColor),
        bodyMedium: TextStyle(color: AppColors.subtitleTextColor),
        titleLarge:
            TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Top-level widget that handles auth state and routes user to admin/home/login.
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: LoadingView(message: 'Checking session...'),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginScreen();
        }

        // Fetch user document from Firestore
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: AppColors.backgroundColor,
                body: LoadingView(message: 'Loading profile...'),
              );
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
