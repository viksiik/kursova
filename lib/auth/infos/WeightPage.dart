import 'package:flutter/material.dart';
import '../components/ButtonField.dart';
import '../components/AddData.dart';
import '../components/DecimalInput.dart';
import '../components/DialogMessage.dart';
import '../components/Indicator.dart';
import 'BirthPage.dart';

class WeightPage extends StatelessWidget {
  WeightPage({
    Key? key,
    this.currentValue = 0,
  }) : super(key: key);

  final weightController = TextEditingController();
  final int currentValue;
  final FirestoreHelper firestoreHelper = FirestoreHelper();

  @override
  void dispose() {
    weightController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFE6B7FF),
        appBar: AppBar(
          backgroundColor: Color(0xFFE6B7FF),
          flexibleSpace: Center(
            child: Indicator(currentValue: 2),
          ),
        ),
        body: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                    child: DecimalInput(
                      controller: weightController,
                      hintText: 'Weight',
                      obscureText: false,
                    ),
                  ),

                Container(
                  margin: const EdgeInsets.only(top: 36.0, left: 40.0, right: 40.0),
                  child: ButtonField(
                      onTap: () {
                      final _inputedWeight = double.tryParse(weightController.text);

                      if (_inputedWeight != null) {

                        firestoreHelper.setData(
                          "users",
                          {"Weight": _inputedWeight},
                        );

                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => BirthdayPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                      } else {
                        ErrorDialog.show(context, 'Please enter a valid weight.', 'Error');
                      }
                    },
                    buttonText: "Next",
                  ),
                )

              ],
              ),
            )
        )
    );
  }
}