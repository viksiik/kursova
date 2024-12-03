import 'package:firebase_auth/firebase_auth.dart';
import 'package:kurs/components/ButtonField.dart';
import 'package:kurs/components/LogoImage.dart';
import 'package:kurs/infos/GenderPage.dart';

import '../components/DialogMessage.dart';
import '../services/GoogleSignIn.dart';
import 'LoginPage.dart';
import '../components/InputField.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required void Function() onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Виконуємо вхід користувача
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Після успішного входу, перевіряємо стан автентифікації
        User? user = userCredential.user;

        // Close the loading dialog
        Navigator.pop(context);

        if (user != null) {
          // Якщо користувач авторизований, перенаправляємо на HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GenderPage(),),
          );
        } else {
          // Якщо користувач не знайдений, перенаправляємо на welcomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RegisterPage(onTap: () {  },)),
          );
        }
      }
      else {
        ErrorDialog.show(context, 'Passwords don`t match', 'Error');
      }
    } on FirebaseAuthException catch (e) {
      // Close the loading dialog in case of an error
      Navigator.pop(context);

      String errorMessage;

      // Обробка помилок
      if (e.code == 'user-not-found') {
        errorMessage = 'Such user was not found.';
      }
      else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password. Try again.';
      }
      else {
        errorMessage = 'Unable to sign up. Check your email or/and password.\n\n*Maybe you already have an account.';
      }

      ErrorDialog.show(context, errorMessage, 'Error');
    } catch (e) {
      ErrorDialog.show(context, 'Something went wrong. Try again later.', 'Error');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6B7FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                // text
                Container(
                    margin: const EdgeInsets.only(top:64.0, bottom: 24.0),
                    child: const Text("Sign up",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    )
                ),

                // username input
                InputField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),

                //password input
                InputField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),

                //confirm password input
                InputField(
                  controller: confirmPasswordController,
                  hintText: "Confirm password",
                  obscureText: true,
                ),

                //sign in button
                ButtonField(
                  onTap: () {
                    signUserUp(); // Ваш метод входу
                  },
                  buttonText: 'Sign up',
                ),

                // continue with
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  margin: const EdgeInsets.only(top: 36.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[500],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Or continue with',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12.0,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                // gl + gh + fb buttons
                Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LogoImage(
                          imagePath: 'assets/images/google_logo.png',
                          onTap: () => GoogleAuthService().signInWithGoogle(context),),
                        const SizedBox(width: 32.0),
                        LogoImage(
                          imagePath: 'assets/images/github_logo.png',
                          onTap: () => GoogleAuthService().signInWithGoogle(context),
                        ),
                        const SizedBox(width: 32.0),
                        LogoImage(
                          imagePath: 'assets/images/fb_logo.png',
                          onTap: () => GoogleAuthService().signInWithGoogle(context),
                        ),
                      ]
                  ),
                ),

                // sign up
                Container(
                  margin: const EdgeInsets.only(top: 104),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 52),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage(onTap: () {  },)),
                          );
                        },
                        child: const Text(
                          'Login now',
                          style: TextStyle(
                            color: Color(0xFF3763FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}