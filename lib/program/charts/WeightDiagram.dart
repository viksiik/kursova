import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kurs/program/pages/WeightBalancePage.dart';

import '../../main.dart';

class WeightBalanceWidget extends StatefulWidget {
  const WeightBalanceWidget({super.key});

  @override
  State<WeightBalanceWidget> createState() => _WeightBalanceWidgetState();
}

class _WeightBalanceWidgetState extends State<WeightBalanceWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;
  Map<DateTime, double> weightData = {};
  double todayWeight = 0.0;
  double goalWeight = 0.0;
  double averageWeight = 0.0;

  @override
  void initState() {
    super.initState();
    fetchWeightData();
    fetchWeightGoal();
  }

  void fetchWeightData() {
    final user = _auth.currentUser;
    if (user == null) return;

    userId = user.uid;
    DateTime today = DateTime.now();
    int currentMonth = today.month;
    int currentYear = today.year;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('weight_balance')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      Map<DateTime, double> tempData = {};
      double sum = 0;
      int count = 0;

      for (var doc in snapshot.docs) {
        try {
          Map<String, dynamic> rawData = doc.data() as Map<String, dynamic>;
          rawData['amount'] = (rawData['amount'] is int)
              ? (rawData['amount'] as int).toDouble()
              : rawData['amount'];


          double weightAmount = rawData['amount'] ?? 0.0;
          DateTime date = DateTime.parse(doc.id);

          if (date.month == currentMonth && date.year == currentYear) {
            if (!tempData.containsKey(date) || date.isAfter(tempData.keys.last)) {
              tempData[date] = weightAmount;
            }

            print('Checking date: ${date.toString()}');
            print('Weight: $weightAmount');

            if (date.day == today.day &&
                date.month == today.month &&
                date.year == today.year) {
              print('Updating todayWeight: $weightAmount');
              setState(() {
                todayWeight = weightAmount;  // Оновлення todayWeight
              });
            }

            sum += weightAmount;
            count++;
          }
        } catch (e) {
          print("Error parsing document: $e");
        }
      }

      setState(() {
        weightData = tempData;
        averageWeight = count > 0 ? sum / count : 0;
      });
    });
  }


  List<FlSpot> _generateChartDataForMonth() {
    List<DateTime> sortedDates = weightData.keys.toList()..sort();
    return List.generate(sortedDates.length, (index) {
      DateTime date = sortedDates[index];
      // Виправлення: тут додаємо правильну дату
      return FlSpot(index.toDouble(), weightData[date]?.toDouble() ?? 0);
    });
  }

  double _calculateMaxY() {
    double maxDataValue = weightData.values.isNotEmpty
        ? weightData.values.reduce((a, b) => a > b ? a : b).toDouble()
        : 0;
    return max(maxDataValue, goalWeight.toDouble()) + 5; // Increased buffer for weight
  }

  Future<void> fetchWeightGoal() async {
    final user = _auth.currentUser;
    if (user == null) return;

    userId = user.uid;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          goalWeight = (data['weightGoal'] as num?)?.toDouble() ?? 0;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
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
                "Weight Balance",
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
                  size: 20,
                ),
                onPressed: () {
                  navigatorKey.currentState?.push(
                    MaterialPageRoute(
                      builder: (context) => WeightBalancePage(), // Замість NewPage ваша нова сторінка
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
                  _buildStatColumn('Today', '${todayWeight.toStringAsFixed(1)} kg'),
                  const SizedBox(width: 16.0),
                  _buildStatColumn('Goal', '$goalWeight kg'),
                ],
              ),
              _buildStatColumn(
                  'Average', '${averageWeight.toStringAsFixed(1)} kg'),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "${value.toStringAsFixed(1)}",
                            style: const TextStyle(color: Colors.black38,
                              fontSize: 10,
                              fontFamily: 'Montserrat',),
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
                          weightData.keys.toList()..sort();
                          if (value.toInt() < sortedDates.length) {
                            DateTime date = sortedDates[value.toInt()];
                            return Text(
                              "${date.day}",
                              style: const TextStyle(
                                color: Colors.black38,
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
                        y: goalWeight.toDouble(),
                        color: Color(0xFFE6B7FF),
                        strokeWidth: 2,
                        dashArray: [10, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (line) => "Goal: $goalWeight kg",
                          style: const TextStyle(
                            color: Color(0xFFE6B7FF),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      HorizontalLine(
                        y: averageWeight.toDouble(),
                        color: Color(0xFF8CEAF2).withOpacity(0.3),
                        strokeWidth: 2,
                        label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (line) => "Avg: ${averageWeight.toStringAsFixed(1)} kg",
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
                      spots: _generateChartDataForMonth(),
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
          ),
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
                fontFamily: 'Montserrat')),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'Montserrat')),
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
