import 'package:firebase_auth/firebase_auth.dart';
import 'package:kurs/components/ButtonField.dart';
import 'package:kurs/components/LogoImage.dart';
import 'package:kurs/pages/ForgotPasswordPage.dart';
import 'package:kurs/infos/GenderPage.dart';
import 'package:kurs/services/GoogleSignIn.dart';

import '../components/DialogMessage.dart';
import '../services/GithubSignIn.dart';
import 'RegisterPage.dart';
import '../components/InputField.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required void Function() onTap}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
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
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
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
          MaterialPageRoute(builder: (context) => GenderPage(),
        ),);
      } else {
        // Якщо користувач не знайдений, перенаправляємо на welcomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegisterPage(onTap: () {  },)),
        );
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
        errorMessage = 'Unable to sign in. Check your email or/and password.';
      }

      ErrorDialog.show(
          context, errorMessage, 'Error');

    } catch (e) {
      // Для несподіваних помилок
      ErrorDialog.show(
         context, 'Something went wrong. Please try again.', 'Error');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                  margin: const EdgeInsets.only(top:96.0, bottom: 32.0),
                  child: const Text("Sign in",
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
            
                //forgot password
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 8.0 ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return ForgotPasswordPage();
                              }));
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xFF3763FF),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
            
                //sign in button
                ButtonField(
                  onTap: () {
                    signUserIn();
                  },
                  buttonText: 'Sign in',
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
            
                // gl + ln + fb buttons
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
                          onTap: () => GithubAuthService().signInWithGithub(context),
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
                      Text(
                        'Don`t have an account?',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 52),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterPage(onTap: () {  },)),
                          );
                        },
                        child: const Text(
                          'Register now',
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