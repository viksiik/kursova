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
              _totalDays = weeks * 9;
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

  /// Відмічає день як виконаний.
  Future<void> _markDayAsCompleted(int dayNumber) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || widget.programId.isEmpty) {
      print('Error: Invalid user or program ID');
      return;
    }

    if (dayNumber > _completedDays) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('currentProgram')
            .doc(widget.programId)
            .set({
          'doneDays': dayNumber,
          'totalDays': _totalDays, // Оновлення totalDays
          'completedDates': FieldValue.arrayUnion([DateTime.now().toIso8601String()]),
        }, SetOptions(merge: true));

        setState(() {
          _completedDays = dayNumber;
        });
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
        ],
      ),
    );
  }
}
