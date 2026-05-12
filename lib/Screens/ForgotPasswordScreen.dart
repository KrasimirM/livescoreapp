import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Widgets/CustomTextField.dart';
import '../Widgets/LoadingView.dart';
import '../constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();

  String _message = '';
  bool _isError = false;
  bool _isSending = false;
  bool _submitted = false;

  Future<void> _sendResetEmail() async {
    if (_isSending) return;

    setState(() {
      _submitted = true;
      _message = '';
      _isError = false;
    });

    final email = _emailController.text.trim();
    final validationError = _validateEmail(email);
    if (validationError.isNotEmpty) {
      setState(() {
        _message = validationError;
        _isError = true;
      });
      return;
    }

    try {
      setState(() => _isSending = true);
      await _auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() {
        _message = 'Password reset email sent. Check your inbox.';
        _isError = false;
        _isSending = false;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _message = _firebaseMessage(e);
        _isError = true;
        _isSending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Could not send reset email. Try again.';
        _isError = true;
        _isSending = false;
      });
    }
  }

  String _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required.';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Enter a valid email.';
    }
    return '';
  }

  String _firebaseMessage(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      return 'No account found with this email.';
    }
    if (e.code == 'invalid-email') {
      return 'Enter a valid email.';
    }
    return e.message ?? 'Could not send reset email. Try again.';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isSending,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Enter your account email and we will send you a password reset link.',
                        style: TextStyle(
                          color: AppColors.subtitleTextColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                      ),
                      if (_submitted && _message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _message,
                            style: TextStyle(
                              color: _isError
                                  ? AppColors.errorColor
                                  : AppColors.primaryColor,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSending ? null : _sendResetEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Send Reset Link',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed:
                            _isSending ? null : () => Navigator.pop(context),
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            color: AppColors.accentColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isSending)
            Container(
              color: AppColors.backgroundColor.withAlpha(219),
              child: LoadingView(message: 'Sending reset email...'),
            ),
        ],
      ),
    );
  }
}
