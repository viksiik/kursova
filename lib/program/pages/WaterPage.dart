import 'dart:math';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;

  Color absColor = Color(0xFFFFDC66);
  Color fullColor = Color(0xFF8587F8);
  Color lowerColor = Color(0xFF8CEAF2);

  Map<DateTime, int> waterData = {}; // Changed from double to int for water
  int todayWater = 0;
  int goalWater = 0;
  int averageWater = 0;

  @override
  void initState() {
    super.initState();
    fetchActivityData();
    fetchWaterGoal();
  }

  Future<void> fetchWaterGoal() async {
    final user = _auth.currentUser;
    if (user == null) return;

    userId = user.uid; // ID користувача

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        print('Fetched data: $data');
        setState(() {
          goalWater = (data['waterGoal'] as num?)?.toInt() ?? 0;
        });
      } else {
        print('No document found for user $userId');
      }

    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void fetchActivityData() async {
    DateTime now = DateTime.now();
    DateTime endDate;

    if (currentUser == null) {
      print("No authenticated user found.");
      return;
    }

    // Adjust the end date based on the selected filter
    switch (selectedFilter) {
      case 'week':
      // End date is the start of the week (Monday)
        endDate = now.subtract(Duration(days: now.weekday - 1)); // Start of the week
        break;
      case 'month':
      // End date is the start of the month
        endDate = DateTime(now.year, now.month, 1); // Start of the month
        break;
      case 'year':
      // End date is the start of the year
        endDate = DateTime(now.year, 1, 1); // Start of the year
        break;
      default:
        endDate = DateTime(2000); // Default case
        break;
    }

    // Fetch the data from Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('water_balance')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      Map<DateTime, int> tempData = {};
      Map<int, List<int>> monthlyData = {};  // For storing water data per month
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

          DateTime date = DateTime.parse(doc.id); // Use doc ID as date

          // Check if the date is after the end date and before today
          if (date.isBefore(now) && date.isAfter(endDate.subtract(Duration(days: 1)))) {
            tempData[date] = waterAmount;

            // For the "year" filter, group by month
            if (selectedFilter == 'year') {
              int month = date.month;
              if (!monthlyData.containsKey(month)) {
                monthlyData[month] = [];
              }
              monthlyData[month]!.add(waterAmount);
            }

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
        // Sorting by date in ascending order
        waterData = Map.fromEntries(tempData.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

        if (selectedFilter == 'year') {
          Map<DateTime, int> monthlyAverages = {};
          monthlyData.forEach((month, amounts) {
            int sum = amounts.reduce((a, b) => a + b);
            int average = (sum / amounts.length).round();  // Rounding to the nearest integer
            DateTime monthDate = DateTime(now.year, month);
            monthlyAverages[monthDate] = average;
          });

          waterData = monthlyAverages; // Update waterData to hold integer monthly averages
        }

        averageWater = count > 0 ? sum ~/ count : 0;
      });
    });
  }

  Future<void> addWaterAmount(int waterAmount) async {
    DateTime now = DateTime.now();
    //String dateString = now.toIso8601String().substring(0, 10); // Отримуємо лише дату без часу
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    try {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .collection('water_balance')
          .doc(formattedDate); // Використовуємо дату як ID документа

      await docRef.set({
        'amount': waterAmount,
        'date': formattedDate, // Store the formatted date as a string
      });

      fetchActivityData(); // Оновлюємо дані після додавання
    } catch (e) {
      print("Error adding water amount: $e");
    }
  }

  void _showAddWaterDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int waterInput = 0;
        return AlertDialog(
          title: const Text(
            "Enter the amount of water",
            style: TextStyle(
              fontFamily: 'Montserrat',
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Дозволяє тільки цифри
              _RangeInputFormatter(0, 5000), // Додаємо обмеження від 0 до 5000
            ],
            onChanged: (value) {
              waterInput = int.tryParse(value) ?? 0;
            },
            decoration: const InputDecoration(
              hintText: "Enter amount in ml",
              hintStyle: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (waterInput > 0 && waterInput <= 300) {
                  await addWaterAmount(waterInput);
                  Navigator.of(context).pop();
                } else {
                  print("Invalid weight input");
                }
              },
              child: const Text(
                "Add",
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddWaterButton() {
    return Center(  // Додаємо обгортку для вирівнювання по центру
      child: ElevatedButton(
        onPressed: _showAddWaterDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8587F8), // Вибір кольору кнопки
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text("Add Water",
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),),
      ),
    );
  }

  Widget buildFilterButton(String filterName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filterName;
        });
        fetchActivityData();
      },
      child: Center(
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
      ),
    );
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
                            selectedFilter == 'month'
                                ? "${date.day}"  // Display only the day if filter is "month"
                                : selectedFilter == 'year'
                                ? "${_getMonthShort(date.month)}"  // Display the month name if filter is "year"
                                : "${date.day} ${_getMonthShort(date.month)}",
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
                    spots: _generateChartDataForLastDays(15),
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
              _buildStatRow('Today', todayWater.toInt()),
              const SizedBox(height: 10),
              _buildStatRow('Goal', goalWater.toInt()),
              const SizedBox(height: 10),
              _buildStatRow('Average', averageWater.toInt()),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildStatRow(String category, int value) {
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
              ' ${value} ml', // Display the value as a rounded double
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

              const SizedBox(height: 20),
              _buildAddWaterButton(),
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

class _RangeInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  _RangeInputFormatter(this.min, this.max);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int? value = int.tryParse(newValue.text);
    if (value != null && value >= min && value <= max) {
      return newValue;
    }
    return oldValue;
  }
}
