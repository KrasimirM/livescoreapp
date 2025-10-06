import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widgets/CustomTextField.dart';
import '../constants.dart';
import 'HomeScreen.dart';

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

  String _generalError = '';
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _submitted = false;

  void _register() async {
    setState(() => _submitted = true);
    final error = _validateForm();
    if (error.isNotEmpty) {
      setState(() => _generalError = error);
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;
      if (user != null) {
        final usersRef = FirebaseFirestore.instance.collection('users');
        final doc = await usersRef.doc(user.uid).get();
        if (!doc.exists) {
          await usersRef
              .doc(user.uid)
              .set({'email': user.email, 'uid': user.uid});
        }
      }
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _generalError = e.message ?? 'Registration error');
    } catch (e) {
      setState(() => _generalError = 'Error: $e');
    }
  }

  String _validateForm() {
    if (_emailController.text.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text)) return 'Enter a valid email';
    if (_passwordController.text.isEmpty) return 'Password is required';
    if (_passwordController.text.length < 6)
      return 'Password must be at least 6 characters';
    if (_confirmPasswordController.text.isEmpty)
      return 'Confirm password is required';
    if (_passwordController.text != _confirmPasswordController.text)
      return 'Passwords do not match';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 24),
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 40),
                  CustomTextField(controller: _emailController, label: 'Email'),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: !_showPassword,
                    toggleVisibility: () =>
                        setState(() => _showPassword = !_showPassword),
                    showToggle: true,
                  ),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: !_showConfirmPassword,
                    toggleVisibility: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword),
                    showToggle: true,
                  ),
                  if (_submitted && _generalError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        _generalError,
                        style: TextStyle(
                            color: AppColors.errorColor, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('Sign Up',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  SizedBox(height: 40),
                  Image.asset(
                    'assets/logo.png',
                    width: 150,
                    height: 150,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Already have an account? Sign In',
                        style: TextStyle(
                            color: AppColors.accentColor, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
