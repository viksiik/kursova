import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../infos/GenderPage.dart';
import '../components/DialogMessage.dart';

class GoogleAuthService {
  Future signInWithGoogle(BuildContext context) async {
    try {
      // Вхід через Google
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        // Якщо користувач відмінив вхід
        return;
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Отримання облікових даних
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Авторизація через Firebase
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Перевірка на успішну авторизацію
      if (userCredential.user != null) {
        // Якщо користувач вперше, Firebase автоматично створить новий акаунт.
        // Перевіряємо, чи користувач новий
        if (userCredential.additionalUserInfo!.isNewUser) {
          // Логіка для нового користувача, наприклад, додавання додаткових даних у базу
          print('New user registered!');
        } else {
          print('Existing user signed in!');
        }

        // Перехід на головну сторінку
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GenderPage()),
        );
      }
    } catch (e) {
      // Обробка помилок
      ErrorDialog.show(context, e.toString(), 'Error');
    }
  }
}
