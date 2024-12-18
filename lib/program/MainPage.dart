import 'package:flutter/material.dart';
import 'package:kurs/program/charts/WeightDiagram.dart';
import '../BottomBar.dart'; // Ваш кастомний BottomNavBar
import '../profile/ProfilePage.dart';
import '../workouts/WorkoutPage.dart';
import 'charts/ActivityChart.dart';
import 'charts/CurrentWoWidget.dart';
import 'charts/MoodChart.dart';
import 'charts/WaterDiagram.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // Індекс вибраної вкладки

  void _onNavTap(int index) {
    if (index == 1) {
      // Перенаправлення на Workouts Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainWorkoutPage()),
      );
    } else if (index == 2) {
      // Перенаправлення на Profile Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserProfilePage()),
      );
    } else {
      // Залишаємося на поточній сторінці
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
           CurrentProgramWidget(),
            const SizedBox(height: 12.0),
            ActivityChart(),
            const SizedBox(height: 4.0),
            const WaterBalanceWidget(),
            const SizedBox(height: 12.0),
            const WeightBalanceWidget(),
            MoodTracker(),
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
