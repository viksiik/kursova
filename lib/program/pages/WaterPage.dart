import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class WaterBalancePage extends StatefulWidget {
  const WaterBalancePage({super.key});

  @override
  State<WaterBalancePage> createState() => _WaterBalancePageState();
}

class _WaterBalancePageState extends State<WaterBalancePage> {
  String selectedFilter = 'week';
  Map<String, double> waterStats = {'amount': 0, 'goal': 0};
  final currentUser = FirebaseAuth.instance.currentUser;

  Color waterColor = Color(0xFF76C7C0);
  Color goalColor = Color(0xFFFBF4FF);

  double waterRounded = 0;
  double goalRounded = 0;

  List<FlSpot> waterDataPoints = [];
  List<FlSpot> goalDataPoints = [];

  @override
  void initState() {
    super.initState();
    fetchWaterData();
  }

  void fetchWaterData() async {
    DateTime now = DateTime.now();
    DateTime startDate;
    int goalWater = 2200;

    if (currentUser == null) {
      print("No authenticated user found.");
      return;
    }

    switch (selectedFilter) {
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1)); // Початок тижня (понеділок)
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1); // Початок місяця
        break;
      case 'year':
        startDate = DateTime(now.year); // Початок року
        break;
      default: // All time
        startDate = DateTime(2000); // Дата для всіх документів
        break;
    }

    final waterRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('water_balance');

    // Додаємо фільтрацію за датою
    QuerySnapshot waterSnapshot = await waterRef.get();

    Map<String, double> tempStats = {'amount': 0};

    waterDataPoints.clear();
    goalDataPoints.clear();

    for (var doc in waterSnapshot.docs) {
      try {
        DateTime date = DateTime.parse(doc.id);

        if (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) {
          double amount = (doc['amount'] is int ? (doc['amount'] as int).toDouble() : doc['amount'] as double) ?? 0.0;
          double goal = goalWater.toDouble();  // Ensure goal is treated as double

          tempStats['amount'] = tempStats['amount']! + amount;
          tempStats['goal'] = goalWater.toDouble(); // Ensure goal is treated as double

          // Ensure both lists are properly initialized with data before usage
          waterDataPoints.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), amount));
          goalDataPoints.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), goal));
        }
      } catch (e) {
        print('Error parsing document: ${doc.id}, Error: $e');
      }
    }

    setState(() {
      waterStats = tempStats;

      // Розрахунок відсотків
      final double sumWater = waterStats['amount']! + waterStats['goal']!;
      if (sumWater > 0) {
        waterRounded = ((waterStats['amount']! / sumWater) * 100).roundToDouble();
        goalRounded = ((waterStats['goal']! / sumWater) * 100).roundToDouble();
      } else {
        waterRounded = 0;
        goalRounded = 0;
      }
    });
  }


  Widget buildFilterButton(String filterName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filterName;
        });
        fetchWaterData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selectedFilter == filterName
              ? Color(0xFF8587F8) // Фіолетове підсвічування при виборі
              : Color(0xFFFBF4FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.1), // Фіолетове обведення
            width: 1, // Товщина обведення
          ),
          boxShadow: selectedFilter == filterName
              ? [
            BoxShadow(
              color: Color(0xFF8587F8).withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3), // Зміщення тіні
            ),
          ]
              : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3), // Зміщення тіні
            ),
          ],
        ),
        child: Text(
          filterName,
          style: TextStyle(
            color: selectedFilter == filterName
                ? Color(0xFFFBF4FF)
                : Colors.black,
            fontWeight:
            selectedFilter == filterName ? FontWeight.w600 : FontWeight.normal,
            fontFamily: 'Montserrat',
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: waterDataPoints,
            isCurved: true,
            color: waterColor,
            belowBarData: BarAreaData(show: true, color: waterColor.withOpacity(0.3)),
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: goalDataPoints,
            isCurved: true,
            color: goalColor,
            belowBarData: BarAreaData(show: true, color: goalColor.withOpacity(0.3)),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBF4FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFBF4FF),
        flexibleSpace: Container(
          margin: const EdgeInsets.only(top: 16.0),
          child: Center(
            child: const Text(
              "Water Balance",
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24.0,
                  fontWeight: FontWeight.w500
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Фільтри
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildFilterButton('week'),
              const SizedBox(width: 8),
              buildFilterButton('month'),
              const SizedBox(width: 8),
              buildFilterButton('year'),
              const SizedBox(width: 8),
              buildFilterButton('all time'),
            ],
          ),
          const SizedBox(height: 32),
          // Графік
          Container(
            height: 300,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildChart(),
          ),
          const SizedBox(height: 24),
          // Підсумки
          Column(
            children: [
              buildStatRow('Water Intake', waterColor, waterRounded),
              const SizedBox(height: 4.0),
              buildStatRow('Goal', goalColor, goalRounded),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildStatRow(String label, Color color, double percentage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 88.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: color, radius: 8),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0
              ),),
            ],
          ),
          Text('$percentage%',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0
              )
          ),
        ],
      ),
    );
  }
}
