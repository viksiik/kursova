import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:kurs/program/MainPage.dart';
import '../components/ButtonField.dart';
import '../components/LogoImage.dart';
import '../pages/ForgotPasswordPage.dart';
import '../infos/GenderPage.dart';
import '../services/GoogleSignIn.dart';

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
  bool isPasswordVisible = false;

  void signUserIn() async {
    if (passwordController.text.length < 6) {
      ErrorDialog.show(
        context,
        'Password must be at least 6 characters long.',
        'Error',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = userCredential.user;

      Navigator.pop(context);

      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      String errorMessage;

      if (e.code == 'user-not-found') {
        errorMessage = 'You are not registered.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password. Try again.';
      } else {
        errorMessage = 'Unable to sign in. Check your email or/and password.';
      }

      ErrorDialog.show(
        context, errorMessage, 'Error',
      );
    } catch (e) {
      ErrorDialog.show(
        context, 'Something went wrong. Please try again.', 'Error',
      );
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
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 96.0, bottom: 32.0),
                  child: const Text(
                    "Sign in",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),

                // username input
                InputField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),

                Container(
                  margin: const EdgeInsets.only(top: 24.0),
                  padding: const EdgeInsets.symmetric(horizontal: 36.0),
                  child: TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                    ],
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Password",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      fillColor: const Color(0xFFFBF4FF),
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey.shade700,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),

                // forgot password
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return ForgotPasswordPage();
                              }));
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: const Color(0xFF3763FF),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // sign in button
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
                        child: Text(
                          'Or continue with',
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

                // gl + gh  buttons
                Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LogoImage(
                          imagePath: 'assets/images/google_logo.png',
                          onTap: () => GoogleAuthService().signInWithGoogle(context),
                        ),
                        const SizedBox(width: 32.0),
                        LogoImage(
                          imagePath: 'assets/images/github_logo.png',
                          onTap: () => GithubAuthService().signInWithGithub(context),
                        ),
                      ]),
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
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(
                                onTap: () {},
                              ),
                            ),
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
