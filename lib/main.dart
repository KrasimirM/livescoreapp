import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/LoginScreen.dart';
import 'package:LiveScore/Widgets/AuthWrapper.dart';
import 'package:LiveScore/Screens/HomeScreen.dart';
import 'package:LiveScore/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/auth': (context) => AuthWrapper(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen()
      },
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: AuthWrapper(),
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
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.accentColor,
        textTheme: ButtonTextTheme.primary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundColor,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.subtitleTextColor,
      ),
    );
  }
}
