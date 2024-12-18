import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/ProgramDetailPage.dart';

class CurrentProgramWidget extends StatefulWidget {

  @override
  _CurrentProgramWidgetState createState() =>
      _CurrentProgramWidgetState();
}

class _CurrentProgramWidgetState extends State<CurrentProgramWidget> {

  final Color progressColor = Color(0xFF8587F8); // Color for progress indicator

  Future<Map<String, dynamic>?> fetchCurrentProgram() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("No authenticated user found.");
      return null;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('currentProgram')
        .get();

    if (snapshot.docs.isEmpty) return null;

    final programData = snapshot.docs.first.data() as Map<String, dynamic>?;

    print('Fetched program data: $programData');
    return programData;
  }


  @override
  void initState() {
    super.initState();
    fetchCurrentProgram();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchCurrentProgram(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final programData = snapshot.data;

        if (programData == null || programData.isEmpty) {
          return Center(
            child: Text("No active program found."),
          );
        }

        return _buildCurrentProgram(context, programData);
      },
    );
  }

  Widget _buildCurrentProgram(BuildContext context, Map<String, dynamic> programData) {
    String programId = programData['title'] ?? 'Unnamed Program';
    final String programName = programData['title'] ?? 'Unnamed Program';
    final int doneDays = int.tryParse(programData['doneDays'].toString()) ?? 0;
    final int totalDays = int.tryParse(programData['totalDays'].toString()) ?? 28;
    final double progress = doneDays / totalDays;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Current Program",
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeightLossProgramDetails(
                        programId: programId,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 124.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        color: progressColor,
                        backgroundColor: Colors.grey[200],
                        strokeWidth: 12.0,
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetail("Program", programName),
                  _buildDetail("Done Days", "$doneDays"),
                  _buildDetail("Total Days", "$totalDays"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
