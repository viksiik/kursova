import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String selectedFilter = 'all time';
  Map<String, int> stats = {'Abs': 0, 'Lower body': 0, 'Full body': 0};
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

    switch (selectedFilter) {
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year);
        break;
      default:
        startDate = DateTime(2000);
        break;
    }

    final activityRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('Activity');

    QuerySnapshot activitySnapshot = await activityRef.get();

    Map<String, int> tempStats = {'Abs': 0, 'Lower body': 0, 'Full body': 0};

    for (var doc in activitySnapshot.docs) {
      try {
        DateTime date = DateTime.parse(doc.id);

        if (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) {
          int absValue = (doc['Abs'] as num?)?.toInt() ?? 0;
          int lowerBodyValue = (doc['Lower body'] as num?)?.toInt() ?? 0;
          int fullBodyValue = (doc['Full body'] as num?)?.toInt() ?? 0;

          tempStats['Abs'] = tempStats['Abs']! + absValue;
          tempStats['Lower body'] = tempStats['Lower body']! + lowerBodyValue;
          tempStats['Full body'] = tempStats['Full body']! + fullBodyValue;
        }
      } catch (e) {
        print('Error parsing document: ${doc.id}, Error: $e');
      }
    }

    setState(() {
      stats = tempStats;

      final double sumActivity = stats['Abs']!.toDouble() + stats['Lower body']!.toDouble() + stats['Full body']!.toDouble();
      if (sumActivity > 0) {
        absRounded = ((stats['Abs']! / sumActivity) * 100).round();
        lowerBodyRounded = ((stats['Lower body']! / sumActivity) * 100).round();
        fullBodyRounded = ((stats['Full body']! / sumActivity) * 100).round();

        int total = absRounded + lowerBodyRounded + fullBodyRounded;
        if (total != 100) {
          final difference = 100 - total;
          if (difference > 0) {
            if (stats['Abs']! >= stats['Lower body']! && stats['Abs']! >= stats['Full body']!) {
              absRounded += difference;
            } else if (stats['Lower body']! >= stats['Full body']!) {
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
              ? Color(0xFF8587F8)
              : Color(0xFFFBF4FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
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
            offset: Offset(0, 3),
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
    final abs = data['Abs'] ?? 0;
    final lowerBody = data['Lower body'] ?? 0;
    final fullBody = data['Full body'] ?? 0;

    final double sumActivity = abs.toDouble() + lowerBody.toDouble() + fullBody.toDouble();

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

          Container(
            height: 200,
            width: 200,
            child: _buildChart({
              'Abs': stats['Abs'],
              'Lower body': stats['Lower body'],
              'Full body': stats['Full body'],
            }),
          ),
          const SizedBox(height: 24),

          Column(
            children: [
              buildStatRow('Abs', abs_color, absRounded),
              const SizedBox(height: 4.0),
              buildStatRow('Lower body', lower_color, lowerBodyRounded),
              const SizedBox(height: 4.0),
              buildStatRow('Full body', full_color, fullBodyRounded),
            ],
          ),

          const SizedBox(height: 32),

          Container(
            margin: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 12.0),
            padding: const EdgeInsets.symmetric(vertical: 16.0),

            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                buildStatNumberRow('Abs', abs_color, stats['Abs'] ?? 0),
                const SizedBox(height: 4.0),
                buildStatNumberRow('Lower body', lower_color, stats['Lower body'] ?? 0),
                const SizedBox(height: 4.0),
                buildStatNumberRow('Full body', full_color, stats['Full body'] ?? 0),
              ],
            ),
          ),

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

  Widget buildStatNumberRow(String label, Color color, int value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 64.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          Text('$value ex.',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

}
