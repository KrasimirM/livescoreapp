import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Widgets/CustomTextField.dart';
import '../constants.dart';
import 'HomeScreen.dart';
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
    setState(() => _submitted = true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.code == 'user-not-found'
          ? 'User not found. Please register.'
          : e.message!);
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    }
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
                    onPressed: _login,
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
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => RegistrationScreen()));
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
    );
  }
}
