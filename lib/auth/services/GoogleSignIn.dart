import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../infos/GenderPage.dart';
import '../components/DialogMessage.dart';

class GoogleAuthService {
  Future signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        return;
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {

        if (userCredential.additionalUserInfo!.isNewUser) {
           print('New user registered!');
        } else {
          print('Existing user signed in!');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GenderPage()),
        );
      }
    } catch (e) {
      ErrorDialog.show(context, e.toString(), 'Error');
    }
  }
}
