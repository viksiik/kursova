import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:github_sign_in_plus/github_sign_in_plus.dart';
import '../components/DialogMessage.dart';
import '../infos/GenderPage.dart';

class GithubAuthService {
  Future<void> signInWithGithub(BuildContext context) async {
    try {
      final GitHubSignIn githubSignIn = GitHubSignIn(
        clientId: 'Ov23ligEqz1vv4urxCWD',
        clientSecret: '2eea44e9c8090e6c43b8cb0fb82726929b885663',
        redirectUrl: 'https://workoutapp-95a25.firebaseapp.com/__/auth/handler',
      );

      final result = await githubSignIn.signIn(context);
      final githubAccessToken = result.token;
      final credential = GithubAuthProvider.credential(
          githubAccessToken!);

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          print('New user registered with GitHub!');
        } else {
          print('Existing user signed in with GitHub!');
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
