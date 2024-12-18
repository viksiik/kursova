import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../main.dart';
import 'WaterPage.dart';

class WeightBalancePage extends StatefulWidget {
  const WeightBalancePage({super.key});

  @override
  State<WeightBalancePage> createState() => _WeightBalancePageState();
}

class _WeightBalancePageState extends State<WeightBalancePage> {
  String selectedFilter = 'week';
  Map<String, double> stats = {'amount': 0};
  final currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;

  Color absColor = Color(0xFFFFDC66);
  Color fullColor = Color(0xFF8587F8);
  Color lowerColor = Color(0xFF8CEAF2);

  Map<DateTime, double> weightData = {}; // Changed from int to double for weight
  double todayWeight = 0.0;
  double goalWeight = 0.0;
  double averageWeight = 0.0;

  @override
  void initState() {
    super.initState();
    fetchActivityData();
    fetchWeightGoal();
  }

  Future<void> fetchWeightGoal() async {
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
          goalWeight = (data['weightGoal'] as num?)?.toDouble() ?? 0;
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
        .collection('weight_balance')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      Map<DateTime, double> tempData = {};
      double sum = 0;
      int count = 0;

      for (var doc in snapshot.docs) {
        try {
          Map<String, dynamic> rawData = doc.data() as Map<String, dynamic>;

          print("Raw data: $rawData");

          double weightAmount = 0.0;
          if (rawData.containsKey('amount')) {
            if (rawData['amount'] is int) {
              weightAmount = (rawData['amount'] as int).toDouble();
            } else if (rawData['amount'] is double) {
              weightAmount = rawData['amount'] as double;
            } else {
              print("Unexpected type for 'amount': ${rawData['amount'].runtimeType}");
            }
          }

          DateTime date = DateTime.parse(doc.id);

          if (date.isAfter(startDate.subtract(Duration(days: 1)))) {
            tempData[date] = weightAmount;

            if (date.year == now.year && date.month == now.month && date.day == now.day) {
              todayWeight = weightAmount;
            }

            sum += weightAmount;
            count++;
          }

        } catch (e) {
          print("Error parsing document: $e");
        }
      }

      print("Fetched weight data: $tempData");

      setState(() {
        weightData = tempData;
        averageWeight = count > 0 ? sum / count : 0;
      });
    });
  }

  // Add the function to add weight data for today
  Future<void> addWeightData(double weight) async {
    final today = DateTime.now();
    final weightRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('weight_balance')
        .doc(today.toIso8601String()); // Use today's date as document ID

    // Check if there's already data for today
    final docSnapshot = await weightRef.get();

    if (docSnapshot.exists) {
      print("Data already exists for today, not adding new entry.");
      return;
    }

    // If no data for today, add the new weight entry
    await weightRef.set({
      'amount': weight,
      'date': today,
    });

    print("Weight data added for today: $weight");
    fetchActivityData(); // Refresh the data
  }

  // Show a dialog to input weight
  void _showWeightInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double weightInput = 0.0;
        return AlertDialog(
          title: Text("Enter Weight", style: TextStyle(fontFamily: 'Montserrat',),),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              weightInput = double.tryParse(value) ?? 0.0;
            },
            decoration: InputDecoration(
                hintText: "Enter your weight",
              hintStyle: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel", style: TextStyle(fontFamily: 'Montserrat',),),
            ),
            TextButton(
              onPressed: () async {
                if (weightInput > 0) {
                  await addWeightData(weightInput);
                  Navigator.of(context).pop();
                } else {
                  print("Invalid weight input");
                }
              },
              child: const Text("Add", style: TextStyle(fontFamily: 'Montserrat',),),
            ),
          ],
        );
      },
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
    double maxDataValue = weightData.isNotEmpty
        ? weightData.values.reduce((a, b) => a > b ? a : b)
        : 0;

    double roundedValue = (max(maxDataValue, 70.0) + 5) / 5;
    roundedValue = (roundedValue).ceilToDouble() * 5;

    return roundedValue;
  }

  List<FlSpot> _generateChartDataForLastDays(int days) {
    List<DateTime> sortedDates = weightData.keys.toList()..sort();
    final int startIndex = sortedDates.length > days
        ? sortedDates.length - days
        : 0;

    return List.generate(sortedDates.length - startIndex, (index) {
      DateTime date = sortedDates[index];
      return FlSpot(index.toDouble(), weightData[date]?.toDouble() ?? 0);
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
                      reservedSize: 50,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${value.toStringAsFixed(1)} kg",
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
                        final List<DateTime> sortedDates = weightData.keys.toList()..sort();
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
                        labelResolver: (line) =>
                        "Avg: ${averageWeight.toStringAsFixed(1)} kg",
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
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(show: true),
                  ),
                ],
                backgroundColor: Colors.white.withOpacity(0.4),
              ),
            ),
          ),
          // Stats
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16.0),
              _buildStatRow('Today', todayWeight.toDouble()),
              const SizedBox(height: 10),
              _buildStatRow('Goal', goalWeight.toDouble()),
              const SizedBox(height: 10),
              _buildStatRow('Average', averageWeight.toDouble()),
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
              ' ${value.toStringAsFixed(1)} kg', // Display the value as a rounded double
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

  String _getMonthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildAddWeightButton() {
    return Center(  // Додаємо обгортку для вирівнювання по центру
      child: ElevatedButton(
        onPressed: _showWeightInputDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8587F8), // Вибір кольору кнопки
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text("Add Weight",
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),),
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
              child: const Text("Weight Balance",
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
                children: [const SizedBox(height: 8),
                  buildFilterButton('week'),
                  const SizedBox(width: 8),
                  buildFilterButton('month'),
                  const SizedBox(width: 8),
                  buildFilterButton('year'),
                ],
              ),
              SizedBox(height: 16),
              _buildChart(stats),

              const SizedBox(height: 20),
              _buildAddWeightButton(),
            ],
          ),
        ),
      ),
    );
  }
}
