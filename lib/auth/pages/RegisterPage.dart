import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../components/ButtonField.dart';
import '../components/LogoImage.dart';
import '../infos/GenderPage.dart';

import '../components/AddData.dart';
import '../components/DialogMessage.dart';
import '../services/GoogleSignIn.dart';
import 'LoginPage.dart';
import '../components/InputField.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required void Function() onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final FirestoreHelper firestoreHelper = FirestoreHelper();
  bool isPasswordVisible = false;

  void signUserUp() async {
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
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        User? user = userCredential.user;

        firestoreHelper.setData(
          "users",
          {"Email": emailController.text.trim()},
        );

        Navigator.pop(context);

        if (user != null) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  GenderPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterPage(
                onTap: () {},
              ),
            ),
          );
        }
      } else {
        ErrorDialog.show(context, 'Passwords don`t match', 'Error');
      }
    } on FirebaseAuthException catch (e) {

      Navigator.pop(context);

      String errorMessage;

      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak.';
      } else {
        errorMessage =
        'Unable to sign up. Check your email or password.\n\n*Maybe you already have an account.';
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

                Container(
                  margin: const EdgeInsets.only(top: 24.0),
                  padding: const EdgeInsets.symmetric(horizontal: 36.0),
                  child: TextField(
                    controller: confirmPasswordController,
                    obscureText: !isPasswordVisible,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                    ],
                    decoration: InputDecoration(
                      labelText: "Confirm password",
                      hintText: "Confirm password",
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

                ButtonField(
                  onTap: () {
                    signUserUp();
                  },
                  buttonText: 'Sign up',
                ),

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

                // gl + gh buttons
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