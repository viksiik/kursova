import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'LoginPage.dart';

class HomePage extends StatelessWidget {
  HomePage ( {super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void SignUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate to LoginPage after sign-out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(onTap: () {  },)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              SignUserOut(context); // Pass context here
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Text("Logged in as "+user.email!),
      ),
    );

  }
}