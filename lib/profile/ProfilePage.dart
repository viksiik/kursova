import 'package:flutter/material.dart';
import 'package:kurs/program/charts/WeightDiagram.dart';

import '../BottomBar.dart';
import '../program/MainPage.dart';
import '../workouts/WorkoutPage.dart';

class MainProfilePage extends StatefulWidget {
  const MainProfilePage({super.key});

  @override
  _MainProfilePageState createState() => _MainProfilePageState();
}

class _MainProfilePageState extends State<MainProfilePage> {
  int _currentIndex = 2; // Індекс вибраної вкладки

  void _onNavTap(int index) {
    if (index == 0) {
      // Перенаправлення на Home Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else if (index == 1) {
      // Перенаправлення на Workouts Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainWorkoutPage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF4FF),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 64.0),
            const SizedBox(height: 4.0),
            const SizedBox(height: 12.0),
            const WeightBalanceWidget(),
            //BottomNav()
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
