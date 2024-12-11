import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityChart extends StatelessWidget {
  Future<Map<String, dynamic>> fetchActivityData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("No authenticated user found.");
    }

    final activityDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('Activity') // Доступ до підколекції
        .doc('Activity'); // Доступ до документа "Activity"

    final docSnapshot = await activityDocRef.get();

    if (!docSnapshot.exists) {
      // Якщо документа не існує, створюємо його з початковими даними
      await activityDocRef.set({
        'abs': 0,
        'lower_body': 0,
        'full_body': 0,
      });

      // Повертаємо початкові дані
      return {
        'abs': 0,
        'lower_body': 0,
        'full_body': 0,
      };
    }

    return docSnapshot.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchActivityData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}\n${snapshot.stackTrace}"),
          );
        } else {
          Color abs_color = Color(0xFFFFDC66);
          Color full_color = Color(0xFF8587F8);
          Color lower_color = Color(0xFF8CEAF2);

          final data = snapshot.data!;
          final abs = data['abs'] ?? 0;
          final lowerBody = data['lower_body'] ?? 0;
          final fullBody = data['full_body'] ?? 0;

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
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 24.0),
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
                const Text(
                  "Activity",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12.0),

                Container(
                  margin: const EdgeInsets.only(left: 8.0, right: 16.0),
                  child: Row(
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegend(abs_color, "Abs", absRounded),
                          _buildLegend(lower_color, "Lower Body", lowerBodyRounded),
                          _buildLegend(full_color, "Full Body", fullBodyRounded),
                        ],
                      ),
                    ],
                  ),
                )

              ],
            ),
          );
        }
      },
    );
  }
}

Widget _buildLegend(Color color, String label, int value) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child:
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
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
              '$label:  ',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
            Text(
              '$value%',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
    );
}

