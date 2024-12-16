import 'package:flutter/material.dart';
import 'package:kurs/program/charts/WeightDiagram.dart';
import '../BottomBar.dart'; // Ваш кастомний BottomNavBar
import 'charts/ActivityChart.dart';
import 'charts/WaterDiagram.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF4FF),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 32.0),
            ActivityChart(),
            const SizedBox(height: 4.0),
            const WaterBalanceWidget(),
            const SizedBox(height: 12.0),
            const WeightBalanceWidget(),
          ],
        ),
      ),
      //bottomNavigationBar: BottomNav(),
    );
  }
}
