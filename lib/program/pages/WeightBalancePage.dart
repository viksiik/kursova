import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class WeightBalancePage extends StatefulWidget {
  const WeightBalancePage({super.key});

  @override
  State<WeightBalancePage> createState() => _WeightBalancePageState();
}

class _WeightBalancePageState extends State<WeightBalancePage> {
  String selectedFilter = 'day';
  Map<String, int> stats = {'abs': 0, 'lower_body': 0, 'full_body': 0};
  final currentUser = FirebaseAuth.instance.currentUser;

  Color abs_color = Color(0xFFFFDC66);
  Color full_color = Color(0xFF8587F8);
  Color lower_color = Color(0xFF8CEAF2);

  int absRounded = 0;
  int lowerBodyRounded = 0;
  int fullBodyRounded = 0;

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

    // Визначаємо startDate відповідно до обраного фільтру
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

    final activityRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('Activity');

    // Додаємо фільтрацію за датою
    QuerySnapshot activitySnapshot = await activityRef.get();

    Map<String, int> tempStats = {'abs': 0, 'lower_body': 0, 'full_body': 0};

    for (var doc in activitySnapshot.docs) {
      try {
        // ID документів — це дати
        DateTime date = DateTime.parse(doc.id);

        if (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) {
          int absValue = (doc['abs'] as num?)?.toInt() ?? 0;
          int lowerBodyValue = (doc['lower_body'] as num?)?.toInt() ?? 0;
          int fullBodyValue = (doc['full_body'] as num?)?.toInt() ?? 0;

          tempStats['abs'] = tempStats['abs']! + absValue;
          tempStats['lower_body'] = tempStats['lower_body']! + lowerBodyValue;
          tempStats['full_body'] = tempStats['full_body']! + fullBodyValue;
        }
      } catch (e) {
        print('Error parsing document: ${doc.id}, Error: $e');
      }
    }

    setState(() {
      stats = tempStats;

      final double sumActivity = stats['abs']!.toDouble() + stats['lower_body']!.toDouble() + stats['full_body']!.toDouble();
      if (sumActivity > 0) {
        absRounded = ((stats['abs']! / sumActivity) * 100).round();
        lowerBodyRounded = ((stats['lower_body']! / sumActivity) * 100).round();
        fullBodyRounded = ((stats['full_body']! / sumActivity) * 100).round();

        // Корекція відсотків
        int total = absRounded + lowerBodyRounded + fullBodyRounded;
        if (total != 100) {
          final difference = 100 - total;
          if (difference > 0) {
            if (stats['abs']! >= stats['lower_body']! && stats['abs']! >= stats['full_body']!) {
              absRounded += difference;
            } else if (stats['lower_body']! >= stats['full_body']!) {
              lowerBodyRounded += difference;
            } else {
              fullBodyRounded += difference;
            }
          }
        }
      } else {
        absRounded = 0;
        lowerBodyRounded = 0;
        fullBodyRounded = 0;
      }
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
              offset: Offset(0, 3), // Зміщення тіні
            ),
          ]
              : [BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3), // Зміщення тіні
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

  Widget _buildChart(Map<String, dynamic> data) {
    final abs = data['abs'] ?? 0;
    final lowerBody = data['lower_body'] ?? 0;
    final fullBody = data['full_body'] ?? 0;

    final double sumActivity = abs.toDouble() + lowerBody.toDouble() + fullBody.toDouble();

    // Створимо змінні для відсотків
    late int absRounded, lowerBodyRounded, fullBodyRounded;

    List<PieChartSectionData> sections = [
      PieChartSectionData(
        value: 100,
        title: '',
        color: abs_color,
        radius: 16,
      ),
    ];

    if (sumActivity > 0) {
      final double absPercentage = (abs / sumActivity) * 100;
      final double lowerBodyPercentage = (lowerBody / sumActivity) * 100;
      final double fullBodyPercentage = (fullBody / sumActivity) * 100;

      absRounded = absPercentage.round();
      lowerBodyRounded = lowerBodyPercentage.round();
      fullBodyRounded = fullBodyPercentage.round();

      // Корекція відсотків до 100%
      int total = absRounded + lowerBodyRounded + fullBodyRounded;
      if (total != 100) {
        final difference = 100 - total;

        if (difference > 0) {
          if (absPercentage >= lowerBodyPercentage && absPercentage >= fullBodyPercentage) {
            absRounded += difference;
          } else if (lowerBodyPercentage >= fullBodyPercentage) {
            lowerBodyRounded += difference;
          } else {
            fullBodyRounded += difference;
          }
        }
      }

      sections = [
        PieChartSectionData(
          value: absRounded.toDouble(),
          title: '',
          color: abs_color,
          radius: 16,
        ),
        PieChartSectionData(
          value: lowerBodyRounded.toDouble(),
          title: '',
          color: lower_color,
          radius: 16,
        ),
        PieChartSectionData(
          value: fullBodyRounded.toDouble(),
          title: '',
          color: full_color,
          radius: 16,
        ),
      ];
    }

    return PieChart(
      PieChartData(sections: sections),
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
              child: const Text("Activity",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          )
      ),
      body: Column(
        children: [
          // Фільтри
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [const SizedBox(height: 8),
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
            height: 200,
            width: 200,
            child: _buildChart({
              'abs': stats['abs'],
              'lower_body': stats['lower_body'],
              'full_body': stats['full_body'],
            }),
          ),
          const SizedBox(height: 24),
          // Підсумки
          Column(
            children: [
              buildStatRow('Abs', abs_color, absRounded),
              const SizedBox(height: 4.0),
              buildStatRow('Lower body', lower_color, lowerBodyRounded),
              const SizedBox(height: 4.0),
              buildStatRow('Full body', full_color, fullBodyRounded),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildStatRow(String label, Color color, int percentage) {
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
          ) ,
        ],
      ),
    );
  }

}
