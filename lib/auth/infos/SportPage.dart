import 'package:flutter/material.dart';
import 'package:kurs/program/MainPage.dart';

import '../components/AddData.dart';
import '../components/ButtonField.dart';
import '../components/DialogMessage.dart';
import '../components/Indicator.dart';

class SportLevelPage extends StatefulWidget {
  const SportLevelPage({
    Key? key,
    this.currentValue = 0,
  }) : super(key: key);

  final int currentValue;

  @override
  _SportLevelPageState createState() => _SportLevelPageState();
}

class _SportLevelPageState extends State<SportLevelPage> {
  String? _selectedLevel;
  final FirestoreHelper firestoreHelper = FirestoreHelper();

  void _selectLevel(String level) {
    setState(() {
      _selectedLevel = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6B7FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFE6B7FF),
        flexibleSpace: Center(
          child: Indicator(currentValue: 4), // Розміщуємо Indicator по центру AppBar
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/sport_img.png',
              height: 200.0,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8.0),
            const Text(
              "Your sport level",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24.0),
            _buildLevelOption(
              title: "Beginner",
              subtitle: "do sport 1-3 times a month",
              level: "beginner",
            ),
            const SizedBox(height: 16.0),
            _buildLevelOption(
              title: "Advanced",
              subtitle: "do sport 2-3 times a week",
              level: "advanced",
            ),
            const SizedBox(height: 16.0),
            _buildLevelOption(
              title: "Professional",
              subtitle: "do sport 4-6 times a week",
              level: "professional",
            ),
            Container(
              margin: const EdgeInsets.only(top: 24.0, left: 40.0, right: 40.0),
              child: ButtonField(
                onTap: () {
                  if (_selectedLevel != null) {
                    firestoreHelper.setData(
                      "users",
                      {"SportLevel": _selectedLevel},
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const MainPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          // Тут ми застосовуємо FadeTransition
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                          (route) => false, // Очищає стек, не дозволяючи повертатися назад
                    );

                  } else {
                    ErrorDialog.show(context, 'Please select a sport level.', 'Error');
                  }
                },
                buttonText: "Done",
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLevelOption({
    required String title,
    required String subtitle,
    required String level,
  }) {
    final bool isSelected = _selectedLevel == level;

    return GestureDetector(
      onTap: () => _selectLevel(level),
      child: Container(
        padding: const EdgeInsets.only(left: 32.0, right: 100.0, top: 12.0, bottom: 12.0),
        margin: const EdgeInsets.symmetric(horizontal: 32.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: isSelected
              ? Border.all(color: const Color(0xFF8CEAF2), width: 2.0)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
