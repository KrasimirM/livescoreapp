import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widgets/CustomTextField.dart';
import '../Widgets/LoadingView.dart';
import '../constants.dart';
import 'RegistrationScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _showPassword = false;
  bool _submitted = false;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _resetForm();
  }

  void _resetForm() {
    _submitted = false;
    _errorMessage = '';
    _emailController.clear();
    _passwordController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void _login() async {
    if (_isLoggingIn) return;

    setState(() => _submitted = true);
    try {
      setState(() {
        _isLoggingIn = true;
        _errorMessage = '';
      });

      final credential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;

      final user = credential.user;
      if (user == null) {
        setState(() {
          _errorMessage = 'Could not load user profile.';
          _isLoggingIn = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!mounted) return;

      final userData = userDoc.data();
      final isAdmin = userData?['is_admin'] == true;
      Navigator.pushNamedAndRemoveUntil(
        context,
        isAdmin ? '/admin' : '/home',
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.code == 'user-not-found'
              ? 'User not found. Please register.'
              : e.message!;
          _isLoggingIn = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoggingIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoggingIn,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 24),
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 40),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                        ),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: !_showPassword,
                          toggleVisibility: () =>
                              setState(() => _showPassword = !_showPassword),
                          showToggle: true,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isLoggingIn
                                ? null
                                : () => Navigator.pushNamed(
                                    context, '/forgot-password'),
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: AppColors.accentColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        if (_submitted && _errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                  color: AppColors.errorColor, fontSize: 14),
                            ),
                          ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoggingIn ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text('Login',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        SizedBox(height: 24),
                        TextButton(
                          onPressed: _isLoggingIn
                              ? null
                              : () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              RegistrationScreen()));
                                },
                          child: Text('Sign Up',
                              style: TextStyle(
                                  color: AppColors.accentColor, fontSize: 16)),
                        ),
                        SizedBox(height: 20),
                        Image.asset(
                          'assets/logo.png',
                          width: 150,
                          height: 150,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoggingIn)
            Container(
              color: AppColors.backgroundColor.withAlpha(219),
              child: LoadingView(message: 'Signing you in...'),
            ),
        ],
      ),
    );
  }
}
