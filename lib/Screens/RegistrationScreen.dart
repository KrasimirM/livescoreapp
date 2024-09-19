import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/FirestoreService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  Future<void> addUserToFirestore(User user) async {
    final usersRef = FirebaseFirestore.instance.collection('users');

    final userDoc = await usersRef.doc(user.uid).get();
    if (!userDoc.exists) {
      await usersRef.doc(user.uid).set({
        'email': user.email,
        'uid': user.uid,
      });
    }
  }

  void _register() async {
    try {
      if (_validateForm()) {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          await addUserToFirestore(user);
        }
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print(e);
    }
  }

  bool _validateForm() {
    bool isValid = true;
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError = _validateConfirmPassword(
          _passwordController.text, _confirmPasswordController.text);

      if (_emailError.isNotEmpty ||
          _passwordError.isNotEmpty ||
          _confirmPasswordError.isNotEmpty) {
        isValid = false;
      }
    });
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration:
                  InputDecoration(labelText: 'Email', errorText: _emailError),
              onChanged: (value) {
                setState(() {
                  _emailError = _validateEmail(value);
                });
              },
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                  labelText: 'Password', errorText: _passwordError),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _passwordError = _validatePassword(value);
                });
              },
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  errorText: _confirmPasswordError),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _confirmPasswordError =
                      _validateConfirmPassword(_passwordController.text, value);
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  String _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return '';
  }

  String _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return '';
  }

  String _validateConfirmPassword(String password, String value) {
    if (value.isEmpty) {
      return 'Confirm Password is required';
    } else if (password != value) {
      return 'Passwords do not match';
    }
    return '';
  }
}
