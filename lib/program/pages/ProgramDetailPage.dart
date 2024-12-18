import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeightLossProgramDetails extends StatefulWidget {
  final String programId; // ID програми

  const WeightLossProgramDetails({
    Key? key,
    required this.programId,
  }) : super(key: key);

  @override
  _WeightLossProgramDetailsState createState() =>
      _WeightLossProgramDetailsState();
}

class _WeightLossProgramDetailsState extends State<WeightLossProgramDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _days = [];
  int _completedDays = 0;
  int _totalDays = 0;

  @override
  void initState() {
    super.initState();
    fetchProgramDetails();
    fetchUserProgress();
    fetchProgramDays();
  }

  Future<void> fetchProgramDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final doc = await _firestore.collection('programs').doc(widget.programId).get();
      if (doc.exists) {
        String duration = doc['duration'] ?? '';
        print('Duration: $duration'); // Виводимо значення duration для перевірки

        // Використовуємо регулярний вираз для витягування числа з рядка
        final match = RegExp(r'(\d+)').firstMatch(duration);

        if (match != null) {
          final weeks = int.tryParse(match.group(0) ?? '0') ?? 0;
          print('Weeks: $weeks'); // Виводимо число тижнів, щоб перевірити

          if (weeks > 0) {
            setState(() {
              _totalDays = weeks * 7;
            });
            print('Total Days: $_totalDays');

            // Тепер, коли ми знаємо totalDays, оновлюємо Firestore
            await _updateTotalDaysInFirestore(); // Викликаємо оновлення totalDays
          } else {
            print('Invalid weeks count');
          }
        } else {
          print('No match found for duration');
        }
      } else {
        print('Program not found');
      }
    } catch (e) {
      print('Error fetching program details: $e');
    }
  }

  Future<void> _updateTotalDaysInFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || widget.programId.isEmpty) {
      print('Error: Invalid user or program ID');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('currentProgram')
          .doc(widget.programId)
          .set({
        'doneDays': _completedDays,
        'totalDays': _totalDays,
        'completedDates': FieldValue.arrayUnion([DateTime.now().toIso8601String()]),
      }, SetOptions(merge: true));

      print('Updated totalDays: $_totalDays');
    } catch (e) {
      print('Error updating totalDays: $e');
    }
  }


  void fetchProgramDays() {
    _firestore
        .collection('programs')
        .doc(widget.programId)
        .collection('Days')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        _days = snapshot.docs
            .map((doc) => {'day': doc.id, 'data': doc.data()})
            .toList();
      });
    });
  }

  /// Завантажує прогрес користувача (виконані дні).
  Future<void> fetchUserProgress() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('currentProgram')
          .doc(widget.programId)
          .get();

      if (doc.exists) {
        setState(() {
          _completedDays = doc['doneDays'] ?? 0;
        });
      }
      final docRef = _firestore.collection('users').doc(user.uid).collection('currentProgram')
          .doc(widget.programId);

      await docRef.update({
        'totalDays': _totalDays,
      });

      print('Updated totalDays: $_totalDays');
    } catch (e) {
      print('Error fetching user progress: $e');
    }
  }
  /// Перевіряє, чи завершено програму.
  Future<void> _checkProgramCompletion() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || widget.programId.isEmpty) {
      print('Error: Invalid user or program ID');
      return;
    }

    try {
      if (_completedDays == _totalDays) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('currentProgram')
            .doc(widget.programId)
            .update({
          'isActive': false, // Встановлюємо воркаут як неактивний
          'completionDate': DateTime.now().toIso8601String(), // Додаємо дату завершення
        });

        _showMessage("Congratulations! You have completed this program.");

        setState(() {
          // Локально оновлюємо стан, щоб відобразити зміни
          _completedDays = _totalDays;
        });
      }
    } catch (e) {
      print('Error checking program completion: $e');
    }
  }

  /// Завершує програму вручну.
  Future<void> _stopProgramManually() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || widget.programId.isEmpty) {
      print('Error: Invalid user or program ID');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('currentProgram')
          .doc(widget.programId)
          .update({
        'isActive': false, // Зупиняємо воркаут
        'StoppedDate': DateTime.now().toIso8601String(), // Фіксуємо дату зупинки
      });

      _showMessage("Program has been stopped.");

      setState(() {
        _completedDays = 0; // Скидаємо виконані дні
      });
    } catch (e) {
      print('Error stopping program manually: $e');
    }
  }

  /// Функція для показу повідомлення.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  Future<void> _markDayAsCompleted(int dayNumber) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || widget.programId.isEmpty) {
      print('Error: Invalid user or program ID');
      return;
    }

    if (dayNumber > _completedDays) {
      try {
        // Оновлення прогресу користувача в поточній програмі
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('currentProgram')
            .doc(widget.programId)
            .set({
          'doneDays': dayNumber,
          'totalDays': _totalDays,
          'completedDates': FieldValue.arrayUnion([DateTime.now().toIso8601String()]),
        }, SetOptions(merge: true));

        setState(() {
          _completedDays = dayNumber;
        });

        // Завантаження категорії програми
        final programDoc = await _firestore.collection('programs').doc(widget.programId).get();
        if (programDoc.exists) {
          final category = programDoc['category']; // Отримуємо категорію програми
          print('Program category: $category');

          if (category == 'Abs' || category == 'Lower body' || category == 'Full body') {
            final currentDate = DateTime.now();
            final formattedDate =
                "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

            // Create/update the activity data for the category
            await _firestore
                .collection('users')
                .doc(user.uid)
                .collection('Activity')
                .doc(formattedDate) // Використовуємо поточну дату як ідентифікатор документа
                .set({
              category: FieldValue.increment(1), // Збільшуємо відповідну категорію на 1
            }, SetOptions(merge: true));

            print('Incremented $category activity for $formattedDate');

            // Now check and create the other two categories if they don't exist
            final categoriesToCheck = ['Lower body', 'Full body', 'Abs'];
            for (var cat in categoriesToCheck) {
              // If the activity for the category doesn't exist yet, create it
              final activityDoc = await _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('Activity')
                  .doc(formattedDate);

              final activityData = await activityDoc.get();
              if (activityData.exists && !activityData.data()!.containsKey(cat)) {
                // If the category does not exist, add it
                await activityDoc.update({
                  cat: FieldValue.increment(0), // Initialize the category if not already present
                });
                print('Created $cat activity for $formattedDate');
              }
            }

          } else {
            print('Unknown program category: $category');
          }
        } else {
          print('Program document not found');
        }

        // Перевіряємо завершення програми
        await _checkProgramCompletion();
      } catch (e) {
        print('Error updating completed days: $e');
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF4FF),
        title: Center(
          child: Text(
            'Program Details',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Schedule',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
              color: Colors.black,
              fontFamily: 'Montserrat',
            ),
          ),
          Expanded(
            child: _days.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                final dayNumber = index + 1;
                final dayData = day['data'];
                final isCompleted = dayNumber <= _completedDays;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: isCompleted ? Colors.green.shade100 : Colors.purple.shade50,
                  child: ListTile(
                    title: Text(
                      'Day $dayNumber',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...dayData.entries.map<Widget>((entry) => Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontFamily: 'Montserrat',
                          ),
                        )),
                        if (!isCompleted)
                          TextButton(
                            onPressed: () => _markDayAsCompleted(dayNumber),
                            child: const Text(
                              'Mark as Completed',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await _stopProgramManually();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Червоний колір для кнопки
              ),
              child: const Text(
                "Stop Program",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
