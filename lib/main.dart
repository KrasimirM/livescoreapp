import 'package:LiveScore/Screens/HomeScreen.dart';
import 'package:LiveScore/Widgets/AuthWrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/LoginScreen.dart';

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
      theme: ThemeData.dark(),
      home: AuthWrapper(),
    );
  }
}
