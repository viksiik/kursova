import 'package:flutter/material.dart';

import 'auth/pages/RegisterPage.dart';

class welcomeScreen extends StatelessWidget {
  const welcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFE6B7FF),
        body: Container(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 112.0, left: 100.0, right: 100.0),
                  child: Image.asset(
                    'assets/images/bottle_main.png',
                    width: 200.0,
                    height: 330.0,
                    fit: BoxFit.cover,
                  ),
                ),
                const Text(
                  'One step closer \nto a better you',
                  textAlign: TextAlign.center,
            
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: const Text(
                    'Let\'s get started and see\nhow much you can change',
                    textAlign: TextAlign.center,
            
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 96.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8587F8),
                      minimumSize: Size(250.0, 62.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage(onTap: () {  },)),
                      );
                    },
                    child: const Text(
                      'Get started',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
            
              ],
            ),
          ),
        )
    );

  }
}