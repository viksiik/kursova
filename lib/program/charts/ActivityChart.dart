import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kurs/program/pages/ActivityPage.dart';

import '../../main.dart';
import 'UpdatingActivityChart.dart'; // Імпортуйте потрібний файл

class ActivityChart extends StatelessWidget {

  Color abs_color = Color(0xFFFFDC66);
  Color full_color = Color(0xFF8587F8);
  Color lower_color = Color(0xFF8CEAF2);

  Stream<Map<String, int>> fetchActivityData() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("No authenticated user found.");
      return Stream.value({});  // Повертаємо потік з порожнім Map у разі відсутності користувача
    }

    // Підписуємось на зміни у колекції Activity
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('Activity')
        .snapshots()
        .map((snapshot) {
      Map<String, int> activityCount = {
        'Abs': 0,
        'Lower body': 0,
        'Full body': 0,
      };

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('Abs')) {
          activityCount['Abs'] = activityCount['Abs']! + (data['Abs'] as num).toInt();
        }
        if (data.containsKey('Lower body')) {
          activityCount['Lower body'] = activityCount['Lower body']! + (data['Lower body'] as num).toInt();
        }
        if (data.containsKey('Full body')) {
          activityCount['Full body'] = activityCount['Full body']! + (data['Full body'] as num).toInt();
        }
      }

      return activityCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: fetchActivityData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text("No activity data found."),
          );
        } else {
          return _buildChart(snapshot.data!);
        }
      },
    );
  }

  Widget _buildChart(Map<String, int> data) {

    final abs = data['Abs'] ?? 0;
    final lowerBody = data['Lower body'] ?? 0;
    final fullBody = data['Full body'] ?? 0;

    final double sumActivity = abs.toDouble() + lowerBody.toDouble() + fullBody.toDouble();

    int absRounded = 0;
    int lowerBodyRounded = 0;
    int fullBodyRounded = 0;

    List<PieChartSectionData> sections = [
      PieChartSectionData(
        value: 100,
        title: '',
        color: abs_color,
        radius: 12,
      ),
    ];

    if (sumActivity > 0) {
      final double absPercentage = (abs / sumActivity) * 100;
      final double lowerBodyPercentage = (lowerBody / sumActivity) * 100;
      final double fullBodyPercentage = (fullBody / sumActivity) * 100;

      absRounded = absPercentage.round();
      lowerBodyRounded = lowerBodyPercentage.round();
      fullBodyRounded = fullBodyPercentage.round();

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
        } else if (difference < 0) {
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
          title: '', // Приховуємо титул всередині секції
          color: abs_color,
          radius: 12,
        ),
        PieChartSectionData(
          value: lowerBodyRounded.toDouble(),
          title: '', // Приховуємо титул всередині секції
          color: lower_color,
          radius: 12,
        ),
        PieChartSectionData(
          value: fullBodyRounded.toDouble(),
          title: '', // Приховуємо титул всередині секції
          color: full_color,
          radius: 12,
        ),
      ];
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 24.0),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Розподіляє елементи по рядку
            children: [
              const Text(
                "Activity",
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
                      builder: (context) => ActivityPage(), // Замість NewPage ваша нова сторінка
                    ),
                  );
                },
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 124.0,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 45,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegend(abs_color, "Abs", absRounded),
                  _buildLegend(lower_color, "Lower Body", lowerBodyRounded),
                  _buildLegend(full_color, "Full Body", fullBodyRounded),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label, int value) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $value%',
          style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0),
        ),
      ],
    );
  }
}
