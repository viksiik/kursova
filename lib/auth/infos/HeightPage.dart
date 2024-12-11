import 'package:flutter/material.dart';
import '../components/ButtonField.dart';
import '../components/Indicator.dart';
import '../components/InputField.dart';
import '../components/AddData.dart';
import '../components/DecimalInput.dart';
import '../components/DialogMessage.dart';
import 'WeightPage.dart';
import '../components/AddData.dart';

class HeightPage extends StatelessWidget {
  HeightPage({
    Key? key,
    this.currentValue = 0,
  }) : super(key: key);

  final heightController = TextEditingController();
  final int currentValue;
  final FirestoreHelper firestoreHelper = FirestoreHelper();

  @override
  void dispose() {
    heightController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6B7FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFE6B7FF),
        flexibleSpace: Center(
          child: Indicator(currentValue: 1), // Розміщуємо Indicator по центру AppBar
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 112.0, left: 40.0, right: 40.0),
              child: Image.asset(
                'assets/images/height_img.png',
                height: 270.0,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              child: const Text(
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
              child: DecimalInput(
                controller: heightController,
                hintText: 'Height',
                obscureText: false,
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 36.0, left: 40.0, right: 40.0),
              child: ButtonField(
                onTap: () {
                  final _inputedHeight = double.tryParse(heightController.text);

                  if (_inputedHeight != null) {
                    firestoreHelper.setData(
                      "users",
                      {"Height": _inputedHeight},
                    );

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            WeightPage(),
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
                    ErrorDialog.show(context, 'Please enter a valid height.', 'Error');
                  }
                },
                buttonText: "Next",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
