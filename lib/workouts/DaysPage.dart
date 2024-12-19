import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeightLossProgram extends StatefulWidget {
  final String workoutName;
  final String workoutUrl;

  const WeightLossProgram({
    Key? key,
    required this.workoutName,
    required this.workoutUrl,
  }) : super(key: key);

  @override
  _WeightLossProgramState createState() => _WeightLossProgramState();
}

class _WeightLossProgramState extends State<WeightLossProgram> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _days = [];
  String category = "";
  String difficulty = "";
  String duration = "";
  String activeProgram = ''; // Змінна для зберігання активного воркауту
  bool isProgramActive = false;

  @override
  void initState() {
    super.initState();
    fetchProgramDetails();
    fetchProgramDays();
    checkActiveProgram();
  }

  // Перевірка, чи є активний воркаут
  void checkActiveProgram() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('currentProgram')
          .doc(widget.workoutName)
          .get();

      if (doc.exists && doc['isActive'] == true) {
        setState(() {
          activeProgram = doc['programId'] ?? ''; // Перевіряємо, чи є цей воркаут активним
          isProgramActive = activeProgram.isNotEmpty;
        });
      }
    } catch (e) {
      print('Error checking active program: $e');
    }
  }

  void startWorkout() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      // Fetch user's active program
      final currentProgramDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('currentProgram')
          .where('isActive', isEqualTo: true)
          .get();

      // If the user already has an active program
      if (currentProgramDoc.docs.isNotEmpty) {
        // Get the existing active program
        final activeProgramData = currentProgramDoc.docs.first.data();
        final activeProgramId = activeProgramData['programId'];

        // Check if the active program is the same as the one the user wants to start
        if (activeProgramId == widget.workoutName) {
          _showMessage("You are already doing this workout!");
        } else {
          _showMessage("You are already doing another workout!");
        }
        return;
      }

      // Fetch the program document from the 'programs' collection
      final programDoc = await _firestore
          .collection('programs')
          .doc(widget.workoutName)
          .get();

      if (!programDoc.exists) {
        _showMessage("Program not found!");
        return;
      }

      int totalDays = 28;

      // Extract weeks and calculate total days
      final duration = programDoc['duration'] ?? '';
      final match = RegExp(r'(\d+)').firstMatch(duration);

      if (match != null) {
        final weeks = int.tryParse(match.group(0) ?? '0') ?? 0;
        if (weeks > 0) {
          totalDays = weeks * 7;
        }
      }

      final programData = programDoc.data();
      if (programData == null) {
        _showMessage("No data available for this program.");
        return;
      }

      // Add the program to the user's currentProgram collection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('currentProgram')
          .doc(widget.workoutName)
          .set({
        'programId': widget.workoutName,
        'startDate': DateTime.now(),
        'isActive': true, // Set the program as active
        'category': programData['category'] ?? 'Unknown',
        'difficulty': programData['difficulty'] ?? 'Unknown',
        'duration': programData['duration'] ?? 'Unknown',
        'totalDays': totalDays,
        'doneDays': 0,
        'imageUrl': programData['imageUrl'],
        'year': programData['year']
      });

      // Update the local state
      setState(() {
        isProgramActive = true;
        activeProgram = widget.workoutName;
      });

      _showMessage("Workout started successfully!");
    } catch (e) {
      print('Error starting workout: $e');
      _showMessage("An error occurred while starting the workout.");
    }
  }

  // Функція для показу повідомлення
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void fetchProgramDetails() {
    _firestore
        .collection('programs')
        .doc(widget.workoutName)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        setState(() {
          category = doc['category'] ?? 'Unknown';
          difficulty = doc['difficulty'] ?? 'Unknown';
          duration = doc['duration'] ?? 'Unknown';
        });
      }
    }).catchError((error) {
      print('Error fetching program details: $error');
    });
  }

  // Отримання днів програми
  void fetchProgramDays() {
    _firestore
        .collection('programs')
        .doc(widget.workoutName)
        .collection('Days')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        _days = snapshot.docs
            .map((doc) => {'day': doc.id, 'data': doc.data()})
            .toList();
      });
    }, onError: (error) {
      print('Error fetching data: $error');
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
              child: Text(
                widget.workoutName,
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
          )),
      body: Column(
        children: [
          Container(
            width: 360,
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Colors.black.withOpacity(0.3),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              widget.workoutUrl,
              fit: BoxFit.cover,
            ),
          ),

          // Filters Section (Category, Difficulty, Duration)
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProgramInfoContainer(category),
                _buildProgramInfoContainer(difficulty),
                _buildProgramInfoContainer(duration),
              ],
            ),
          ),

          Text(
            'Schedule',
            style: TextStyle(
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
                final exercises = day['data'];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  color: Colors.purple.shade50,
                  child: ListTile(
                    title: Text(
                      'Day ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: exercises.entries
                          .map<Widget>((entry) => Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontFamily: 'Montserrat',
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: startWorkout,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF8587F8),
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0), // Padding inside the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0), // Corner radius
                ),
                elevation: 5, // Button shadow
              ),
              child: Text(
                isProgramActive ? "Resume Workout" : "Start Workout",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500, // Font weight
                ),
              ),
            ),
          )

        ],
      ),
    );
  }

  // Віджет для відображення фільтрів (категорія, складність, тривалість)
  Widget _buildProgramInfoContainer(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3))
        ],
        color: Color(0xFFFBF4FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}
