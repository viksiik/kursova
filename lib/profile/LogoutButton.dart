import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kurs/auth/pages/LoginPage.dart';

class LogoutButton extends StatelessWidget {
  LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final FirebaseAuth _auth = FirebaseAuth.instance;
        try {
          await _auth.signOut();
          print('User logged out successfully');
        } catch (e) {
          print('Error during logout: $e');
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage(onTap: () {  },)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        margin: const EdgeInsets.only(top: 25.0, left: 32.0, right: 32.0),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Center(
          child: Text(
            'Logout',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
