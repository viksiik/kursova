import 'package:firebase_auth/firebase_auth.dart';
import 'package:kurs/components/ButtonField.dart';
import 'package:kurs/components/LogoImage.dart';
import 'package:kurs/pages/HomePage.dart';

import 'package:flutter/material.dart';

import '../components/DialogMessage.dart';
import '../components/InputField.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  Future passwordReset() async {
    try {
      final email = emailController.text.trim();

      if (email.isEmpty) {
        ErrorDialog.show(context, 'Please enter your email.', 'Error');
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      ErrorDialog.show(context,
          'A password reset link has been sent to $email. Please check your email.', 'Check');

    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }

      // Виводимо помилку користувачеві
      ErrorDialog.show(context, errorMessage, 'Error');
    } catch (e) {
      // Виводимо несподівану помилку
      ErrorDialog.show(context, 'An unexpected error occurred.','Error');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6B7FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFE6B7FF),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 64.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text('Enter the email to send the link to reset password.',
              style:
                TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            InputField(
              controller: emailController,
              hintText: "Email",
              obscureText: false,
            ),
            ButtonField(
                onTap: passwordReset,
                buttonText: 'Reset Password'
            ),
          ],
        ),
      ),
    );
  }


}