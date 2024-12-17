import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../main.dart';
import 'WaterPage.dart';

class WaterBalancePage extends StatefulWidget {
  const WaterBalancePage({super.key});

  @override
  State<WaterBalancePage> createState() => _WaterBalancePageState();
}

class _WaterBalancePageState extends State<WaterBalancePage> {
  String selectedFilter = 'week';
  Map<String, int> stats = {'amount': 0};
  final currentUser = FirebaseAuth.instance.currentUser;

  Color absColor = Color(0xFFFFDC66);
  Color fullColor = Color(0xFF8587F8);
  Color lowerColor = Color(0xFF8CEAF2);

  Map<DateTime, int> waterData = {}; // Changed from double to int for water
  int todayWater = 0;
  int goalWater = 2100;
  int averageWater = 0;

  @override
  void initState() {
    super.initState();
    fetchActivityData();
  }

  void fetchActivityData() async {
    DateTime now = DateTime.now();
    DateTime startDate;

    if (currentUser == null) {
      print("No authenticated user found.");
      return;
    }

    switch (selectedFilter) {
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1)); // Start of the week (Monday)
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1); // Start of the month
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(2000);
        break;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('water_balance')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      Map<DateTime, int> tempData = {};
      int sum = 0;
      int count = 0;

      for (var doc in snapshot.docs) {
        try {
          Map<String, dynamic> rawData = doc.data() as Map<String, dynamic>;

          print("Raw data: $rawData");

          int waterAmount = 0;
          if (rawData.containsKey('amount')) {
            if (rawData['amount'] is double) {
              waterAmount = (rawData['amount'] as double).toInt();
            } else if (rawData['amount'] is int) {
              waterAmount = rawData['amount'] as int;
            } else {
              print("Unexpected type for 'amount': ${rawData['amount'].runtimeType}");
            }
          }

          DateTime date = DateTime.parse(doc.id); // Парсимо ID як дату
          //int waterAmount = (doc.data() as Map<String, dynamic>)['amount'] ?? 0;

          if (date.isAfter(startDate.subtract(Duration(days: 1)))) {
            tempData[date] = waterAmount;

            if (date.year == now.year && date.month == now.month && date.day == now.day) {
              todayWater = waterAmount;
            }

            sum += waterAmount;
            count++;
          }

        } catch (e) {
          print("Error parsing document: $e");
        }
      }

      setState(() {
        waterData = tempData;
        averageWater = count > 0 ? sum ~/ count : 0;
      });
    });
  }

  Widget buildFilterButton(String filterName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filterName;
        });
        fetchActivityData();
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
              offset: Offset(0, 3),
            ),
          ]
              : [BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3)
          ),],
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

  double _calculateMaxY() {
    if (waterData.isEmpty) {
      return 2500; // Повертає стандартне значення, якщо немає даних
    }

    int maxDataValue = waterData.values
        .where((value) => value != null) // Фільтруємо null значення
        .fold(0, (prev, value) => max(prev, value)); // Знаходимо максимум

    // Округлення вгору до найближчого кратного 5
    double roundedValue = (max(maxDataValue, 2100) + 400) / 5; // Додаємо 4 для округлення
    roundedValue = roundedValue.ceil() * 5;

    return roundedValue;
  }


  List<FlSpot> _generateChartDataForLastDays(int days) {
    List<DateTime> sortedDates = waterData.keys.toList()..sort();
    final int startIndex = sortedDates.length > days
        ? sortedDates.length - days
        : 0;

    return List.generate(sortedDates.length - startIndex, (index) {
      DateTime date = sortedDates[index];
      return FlSpot(index.toDouble(), waterData[date]?.toDouble() ?? 0.0);  // Double for chart
    });
  }

  Widget _buildChart(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            width: 400,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 500,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${value.toStringAsFixed(0)}",  // Integer format
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'Montserrat',
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final List<DateTime> sortedDates = waterData.keys.toList()..sort();
                        if (value.toInt() < sortedDates.length) {
                          DateTime date = sortedDates[value.toInt()];
                          return Text(
                            "${date.day} ${_getMonthShort(date.month)}",
                            style: const TextStyle(
                              fontSize: 10,
                              fontFamily: 'Montserrat',
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: goalWater.toDouble(),
                      color: Color(0xFFE6B7FF),
                      strokeWidth: 2,
                      dashArray: [10, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        labelResolver: (line) => "Goal: $goalWater ml",
                        style: const TextStyle(
                          color: Color(0xFFE6B7FF),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    HorizontalLine(
                      y: averageWater.toDouble(),
                      color: Color(0xFF8CEAF2).withOpacity(0.3),
                      strokeWidth: 2,
                      label: HorizontalLineLabel(
                        show: true,
                        labelResolver: (line) =>
                        "Avg: ${averageWater.toStringAsFixed(1)} ml",
                        style: const TextStyle(
                          color: Color(0xFF8CEAF2),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
                minY: 0,
                maxY: _calculateMaxY(),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateChartDataForLastDays(7),
                    isCurved: false,
                    color: Color(0xFF8587F8),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(show: true),
                  ),
                ],
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16.0),
              _buildStatRow('Today', todayWater.toDouble()),
              const SizedBox(height: 10),
              _buildStatRow('Goal', goalWater.toDouble()),
              const SizedBox(height: 10),
              _buildStatRow('Average', averageWater.toDouble()),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildStatRow(String category, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$category:', // Display the value as a rounded double
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500
              ),
            ),
            Text(
              ' ${value.toStringAsFixed(1)} ml', // Display the value as a rounded double
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0
              ),
            ),
          ],
        ),
      ],
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
              child: const Text("Water Balance",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildFilterButton('week'),
                  const SizedBox(width: 8),
                  buildFilterButton('month'),
                  const SizedBox(width: 8),
                  buildFilterButton('year'),
                ],
              ),

              const SizedBox(height: 20),
              _buildChart(stats),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
