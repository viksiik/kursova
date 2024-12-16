import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kurs/program/pages/WaterPage.dart';

import '../../main.dart';

class WaterBalanceWidget extends StatefulWidget {
  const WaterBalanceWidget({super.key});

  @override
  State<WaterBalanceWidget> createState() => _WaterBalanceWidgetState();
}

class _WaterBalanceWidgetState extends State<WaterBalanceWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;
  Map<DateTime, int> waterData = {};
  int todayWater = 0;
  int goalWater = 2200; // Ціль для води
  double averageWater = 0.0;

  @override
  void initState() {
    super.initState();
    fetchWaterData();
  }

  void fetchWaterData() {
    final user = _auth.currentUser;
    if (user == null) return;

    userId = user.uid; // ID користувача
    DateTime today = DateTime.now();

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('water_balance')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      Map<DateTime, int> tempData = {};
      int sum = 0;
      int count = 0;

      for (var doc in snapshot.docs) {
        try {
          DateTime date = DateTime.parse(doc.id); // Парсимо ID як дату
          int waterAmount = (doc.data() as Map<String, dynamic>)['amount'] ?? 0;

          tempData[date] = waterAmount;

          // Сьогоднішня кількість
          if (date.day == today.day &&
              date.month == today.month &&
              date.year == today.year) {
            todayWater = waterAmount;
          }

          sum += waterAmount;
          count++;
        } catch (e) {
          print("Error parsing document: $e");
        }
      }

      setState(() {
        waterData = tempData;
        averageWater = count > 0 ? sum / count : 0;
      });
    });
  }

  List<FlSpot> _generateChartData() {
    List<DateTime> sortedDates = waterData.keys.toList()..sort();
    return List.generate(sortedDates.length, (index) {
      DateTime date = sortedDates[index];
      return FlSpot(index.toDouble(), waterData[date]?.toDouble() ?? 0);
    });
  }

  List<FlSpot> _generateChartDataForLastDays(int days) {
    List<DateTime> sortedDates = waterData.keys.toList()..sort();
    final int startIndex = sortedDates.length > days
        ? sortedDates.length - days
        : 0;

    return List.generate(sortedDates.length - startIndex, (index) {
      DateTime date = sortedDates[startIndex + index];
      return FlSpot(index.toDouble(), waterData[date]?.toDouble() ?? 0);
    });
  }

  double _calculateMaxY() {
    double maxDataValue = waterData.values.isNotEmpty
        ? waterData.values.reduce((a, b) => a > b ? a : b).toDouble()
        : 0;
    return max(maxDataValue, goalWater.toDouble()) + 200;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Water Balance",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 20
                ),
                onPressed: () {
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(
                      builder: (context) => WaterBalancePage(), // Замість NewPage ваша нова сторінка
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildStatColumn('Today', '$todayWater ml'),
                  const SizedBox(width: 16.0,),
                  _buildStatColumn('Goal', '$goalWater ml'),
                ],
              ),
              _buildStatColumn(
                  'Average', '${averageWater.toStringAsFixed(0)} ml'),
            ],
          ),
          const SizedBox(height: 20),

      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false, drawVerticalLine: false), // Сітка
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 500,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        "${value.toInt()} ml",
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final List<DateTime> sortedDates =
                      waterData.keys.toList()..sort();
                      if (value.toInt() < sortedDates.length) {
                        DateTime date = sortedDates[value.toInt()];
                        return Text(
                          "${date.day} ${_getMonthShort(date.month)}",
                          style: const TextStyle(fontSize: 10),
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
                      ),
                    ),
                  ),
                  HorizontalLine(
                    y: averageWater.toDouble(),
                    color: Color(0xFF8CEAF2).withOpacity(0.3),
                    strokeWidth: 2,
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (line) => "Avg: ${averageWater.toStringAsFixed(0)} ml",
                      style: const TextStyle(
                        color: Color(0xFF8CEAF2),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              minY: 0,
              maxY: _calculateMaxY(),
              lineBarsData: [
                LineChartBarData(
                  spots: _generateChartDataForLastDays(7), // Останні 7 днів
                  isCurved: false,
                  color: Color(0xFF8587F8),
                  barWidth: 2,
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      )

      ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat'
            )),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'Montserrat'
            )),
      ],
    );
  }

  String _getMonthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

