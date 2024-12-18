import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({Key? key}) : super(key: key);

  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  final Map<String, Color> moodColors = {
    'happy': Color(0xFFFDFF8A),
    'excited': Color(0xFFFF8DEC),
    'neutral': Color(0xFFBFFFD9),
    'sad': Color(0xFF77BDFF),
    'depressed': Color(0xFF996AFF),
  };

  Map<String, String> moodData = {}; // Мапа для збереження даних настроїв
  String selectedMonth = DateFormat('yyyy-MM').format(DateTime.now()); // Поточний місяць

  @override
  void initState() {
    super.initState();
    _fetchMoodData();
  }

  Future<void> _fetchMoodData() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final user = _auth.currentUser; // Отримуємо поточного користувача
    if (user == null) return;

    final String userId = user.uid; // UID користувача

    // Слухаємо зміни в колекції настроїв
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('mood')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      final Map<String, String> moods = {};

      for (var doc in snapshot.docs) {
        final String date = doc.id; // Використовуємо ID документа як дату

        // Фільтруємо дані за обраний місяць
        if (date.startsWith(selectedMonth)) {
          final String mood = doc['mood'] as String;
          moods[date] = mood;
        }
      }

      setState(() {
        moodData = moods; // Оновлюємо стан
      });
    });
  }

  void _changeMonth(String newMonth) {
    setState(() {
      selectedMonth = newMonth; // Оновлюємо обраний місяць
      _fetchMoodData(); // Оновлюємо дані для нового місяця
    });
  }

  // Функція для додавання настрою
  Future<void> _addMood() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final user = _auth.currentUser;
    if (user == null) return;

    final String userId = user.uid;
    String selectedMood = '';

    // Показуємо діалогове вікно для вибору настрою
    await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select your mood'),
          content: SingleChildScrollView(
            child: Column(
              children: moodColors.keys.map((mood) {
                return ListTile(
                  title: Text(mood),
                  leading: CircleAvatar(
                    backgroundColor: moodColors[mood],
                  ),
                  onTap: () {
                    selectedMood = mood;
                    Navigator.of(context).pop(mood); // Закриваємо діалог та передаємо вибір
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        // Отримуємо поточну дату
        final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

        // Додаємо вибраний настрій в Firestore
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('mood')
            .doc(todayDate)
            .set({
          'mood': selectedMood,
        }).then((_) {
          print("Mood added successfully!");
          _fetchMoodData(); // Оновлюємо дані після додавання
        }).catchError((error) {
          print("Error adding mood: $error");
        });
      }
    });
  }

  Widget _buildAddMoodButton() {
    return Center(  // Додаємо обгортку для вирівнювання по центру
      child: ElevatedButton(
        onPressed: _addMood,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8587F8),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text('Add Mood',
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
    final selectedYear = int.parse(selectedMonth.split('-')[0]);
    final selectedMonthNum = int.parse(selectedMonth.split('-')[1]);

    final firstDayOfMonth = DateTime(selectedYear, selectedMonthNum, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday;
    final totalDaysInMonth = DateTime(selectedYear, selectedMonthNum + 1, 0).day;

    return Scaffold(
      backgroundColor: Color(0xFFFBF4FF),
      appBar: AppBar(
          backgroundColor: Color(0xFFFBF4FF),
          flexibleSpace: Container(
            margin: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: const Text("Mood Tracker",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    final previousMonth = DateTime(selectedYear, selectedMonthNum - 1);
                    _changeMonth(DateFormat('yyyy-MM').format(previousMonth));
                  },
                ),
                Expanded(
                  child: Center(
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      items: List.generate(12, (index) {
                        final month = DateFormat('MMMM').format(DateTime(0, index + 1));
                        final monthString = '$selectedYear-${(index + 1).toString().padLeft(2, '0')}';
                        return DropdownMenuItem(
                          value: monthString,
                          child: Text(month, style: TextStyle(fontFamily: 'Montserrat'),),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) _changeMonth(value);
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    final nextMonth = DateTime(selectedYear, selectedMonthNum + 1);
                    _changeMonth(DateFormat('yyyy-MM').format(nextMonth));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((day) => Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 16, ),
                Container(
                  height: 350,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: calculateRowsForMonth(selectedYear, selectedMonthNum) * 7,
                    itemBuilder: (context, index) {
                      // Якщо індекс у перших порожніх клітинках
                      if (index < weekdayOfFirstDay - 1) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300.withOpacity(0.5),
                          ),
                        );
                      }

                      final day = index - (weekdayOfFirstDay - 1) + 1;

                      // Якщо день виходить за межі місяця
                      if (day > totalDaysInMonth) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300.withOpacity(0.5),
                          ),
                        );
                      }

                      final date = '${selectedYear}-${selectedMonthNum.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
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
                SizedBox(height: 20),
                // Кнопка для додавання настрою
                _buildAddMoodButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Допоміжні функції для обчислень
int calculateRowsForMonth(int year, int month) {
  final firstDayOfMonth = DateTime(year, month, 1);
  final weekdayOfFirstDay = firstDayOfMonth.weekday;
  final totalDaysInMonth = DateTime(year, month + 1, 0).day;

  int rows = (totalDaysInMonth + weekdayOfFirstDay - 1) ~/ 7;

  if ((totalDaysInMonth + weekdayOfFirstDay - 1) % 7 != 0) {
    rows++;
  }

  return rows;
}
