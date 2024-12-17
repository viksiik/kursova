import 'package:flutter/material.dart';
import 'package:kurs/program/charts/WeightDiagram.dart';

import '../BottomBar.dart';
import '../profile/ProfilePage.dart';
import '../program/MainPage.dart';

class MainWorkoutPage extends StatefulWidget {
  const MainWorkoutPage({super.key});

  @override
  _MainWorkoutPageState createState() => _MainWorkoutPageState();
}

class _MainWorkoutPageState extends State<MainWorkoutPage> {
  int _currentIndex = 1; // Індекс вибраної вкладки

  void _onNavTap(int index) {
    if (index == 0) {
      // Перенаправлення на Home Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else if (index == 2) {
      // Перенаправлення на Profile Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainProfilePage()),
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
            const SizedBox(height: 32.0),
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
