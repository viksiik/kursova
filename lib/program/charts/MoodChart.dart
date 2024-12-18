import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main.dart';
import '../pages/MoodTrackerPage.dart';

class MoodTracker extends StatefulWidget {
  const MoodTracker({Key? key}) : super(key: key);

  @override
  _MoodTrackerState createState() => _MoodTrackerState();
}

class _MoodTrackerState extends State<MoodTracker> {
  final Map<String, Color> moodColors = {
    'happy': Color(0xFFFDFF8A),
    'excited': Color(0xFFFF8DEC),
    'neutral': Color(0xFFBFFFD9),
    'sad': Color(0xFF77BDFF),
    'depressed': Color(0xFF996AFF),
  };

  Map<String, String> moodData = {};

  @override
  void initState() {
    super.initState();
    _fetchMoodData();
  }

  Future<void> _fetchMoodData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;
    final userId = user.uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('mood')
        .snapshots()
        .listen((snapshot) {
      final Map<String, String> moods = {};
      for (var doc in snapshot.docs) {
        moods[doc.id] = doc['mood'] as String;
      }
      setState(() => moodData = moods);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                    "Mood Tracker",
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
                          builder: (context) =>
                              MoodTrackerPage(), // Navigate to WeightPage
                        ),
                      );
                    },

                  ),
                ],
              ),
              const SizedBox(height: 4.0,),
              Text(
                _getMonthName(DateTime
                    .now()
                    .month),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map((day) =>
                        Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                        .toList(),
                  ),

                  Container(
                    height: 350,
                    //margin: const EdgeInsets.only(bottom: 64.0),
                    // padding: const EdgeInsets.only(bottom: 32.0),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      // Щоб грід не прокручувався
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: calculateRowsForMonth(DateTime
                          .now()
                          .year, DateTime
                          .now()
                          .month) * 7,
                      itemBuilder: (context, index) {
                        final firstDayOfMonth = DateTime(DateTime
                            .now()
                            .year, DateTime
                            .now()
                            .month, 1);
                        final weekdayOfFirstDay = firstDayOfMonth
                            .weekday; // Це день тижня для 1-го числа місяця
                        final totalDaysInMonth = DateTime(DateTime
                            .now()
                            .year, DateTime
                            .now()
                            .month + 1, 0).day; // Кількість днів у місяці

                        final totalCells = _daysInMonth(DateTime
                            .now()
                            .year, DateTime
                            .now()
                            .month);

                        if (index < weekdayOfFirstDay - 1 &&
                            index < totalCells) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade300.withOpacity(0.5),
                            ),
                          );
                        }

                        // Визначаємо день місяця
                        final day = index - (weekdayOfFirstDay - 1) +
                            1; // Визначаємо день місяця

                        // Якщо індекс більший за кількість днів у місяці, повертаємо порожню клітинку
                        if (day > totalDaysInMonth) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade300.withOpacity(
                                  0.5), // Порожні клітинки після останнього дня місяця
                            ),
                          );
                        }

                        final date = '${DateTime
                            .now()
                            .year}-${DateTime
                            .now()
                            .month
                            .toString()
                            .padLeft(2, '0')}-${day.toString().padLeft(
                            2, '0')}';
                        final mood = moodData[date];
                        final color = moodColors[mood] ?? Colors.grey.shade300;

                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },

                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: moodColors.entries.map((entry) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: entry.value,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.key.capitalize(),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  )

                ],
              ),
            ]));
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

String _getMonthName(int month) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return months[month - 1];
}

int _daysInMonth(int year, int month) {
  // Перевіряємо лютий на високосний рік
  if (month == 2) {
    return _isLeapYear(year) ? 29 : 28;
  }

  // Список днів для інших місяців
  List<int> daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  return daysPerMonth[month - 1];
}

// Допоміжний метод для перевірки високосного року
bool _isLeapYear(int year) {
  return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
}

int calculateRowsForMonth(int year, int month) {
  final firstDayOfMonth = DateTime(year, month, 1);
  final weekdayOfFirstDay = firstDayOfMonth.weekday; // День тижня для першого дня місяця
  final totalDaysInMonth = DateTime(year, month + 1, 0).day; // Кількість днів у місяці

  // Рахуємо скільки тижнів (рядків) потрібно для розміщення всіх днів
  int rows = (totalDaysInMonth + weekdayOfFirstDay - 1) ~/ 7;

  // Якщо залишок від ділення є, додаємо ще один рядок
  if ((totalDaysInMonth + weekdayOfFirstDay - 1) % 7 != 0) {
    rows++;
  }

  return rows;
}
