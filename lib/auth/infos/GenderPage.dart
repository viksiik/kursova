import 'package:flutter/material.dart';
import '../components/ButtonField.dart';
import '../components/RadioButtonInput.dart';
import '../infos/HeightPage.dart';
import '../components/AddData.dart';
import '../components/Indicator.dart';

class GenderPage extends StatefulWidget {
  GenderPage({super.key});

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  final genderController = TextEditingController();

  @override
  void dispose() {
    genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6B7FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFE6B7FF),
        flexibleSpace: Center(
          child: Indicator(currentValue: 0),
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 120),
              Image.asset(
                'assets/images/gender_img.png',
                width: 250.0,
                fit: BoxFit.cover,
              ),

              const SizedBox(height: 16),

              const Text(
                "Your gender",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),
              RadioButtonInput(),

              const SizedBox(height: 24),
              ButtonField(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => HeightPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                buttonText: "Next",
              ),
              const SizedBox(height: 40),

            ],

          ),
        ),
      ),
    );
  }
}
