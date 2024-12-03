import 'package:flutter/material.dart';
import 'package:kurs/components/ButtonField.dart';
import 'package:kurs/infos/HeightPage.dart';
import 'package:kurs/components/InputField.dart';

import '../components/Indicator.dart';

class WeightPage extends StatelessWidget {
  WeightPage ({super.key});
  final weightController = TextEditingController();

  @override
  void dispose() {
    weightController.dispose();
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

                  Indicator(currentValue: 2),

                  Container(
                    margin: const EdgeInsets.only(top: 100.0, left: 40.0, right: 40.0),
                    child: Image.asset(
                      'assets/images/weight_img.png',
                      width: 340.0,
                      height: 300.0,
                      fit: BoxFit.fill,
                    ),
                  ),

                  Text(
                    "Your weight",
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,

                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    child: InputField(
                      controller: weightController,
                      hintText: 'Weight',
                      obscureText: false,
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top:36.0, left:40.0, right: 40.0),
                    child: ButtonField(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HeightPage(currentValue: 1)),
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