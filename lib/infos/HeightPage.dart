import 'package:flutter/material.dart';
import 'package:kurs/components/ButtonField.dart';
import 'package:kurs/components/Indicator.dart';
import 'package:kurs/components/InputField.dart';

import 'WeightPage.dart';

class HeightPage extends StatelessWidget {

  HeightPage ({Key? key,
  this.currentValue = 0,
  }) : super(key: key);

  final heightController = TextEditingController();
  final int currentValue;

  @override
  void dispose() {
    heightController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFE6B7FF),
        body: Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Indicator(currentValue: 1),
                  
                  Container(
                    margin: const EdgeInsets.only(top: 112.0, left: 40.0, right: 40.0),
                    child: Image.asset(
                      'assets/images/height_img.png',
                      //width: 175.0,
                      height: 270.0,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Your height",
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    child: InputField(
                      controller: heightController,
                      hintText: 'Height',
                      obscureText: false,
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top:36.0, left:40.0, right: 40.0),
                    child: ButtonField(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WeightPage()),
                        );
                      },
                      buttonText: "Next",
                    ),
                  ),


                ],
              ),
            )
        )
    );
  }
}