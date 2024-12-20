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

  final Color progressColor = Color(0xFF8587F8);

  Stream<Map<String, dynamic>?> fetchCurrentProgram() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("No authenticated user found.");
      return Stream.value(null);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('currentProgram')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final programData = snapshot.docs.first.data() as Map<String, dynamic>?;
      print('Fetched active program data: $programData');
      return programData;
    });
  }


  @override
  void initState() {
    super.initState();
    fetchCurrentProgram();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: fetchCurrentProgram(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final programData = snapshot.data;

        if (programData == null || programData.isEmpty) {
          return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 110.0, vertical: 48.0),
              decoration: BoxDecoration(
                color: Color(0xFFE6B7FF),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text('No active workout',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              )
          );
        }

        return _buildCurrentProgram(context, programData);
      },
    );
  }

  Widget _buildCurrentProgram(BuildContext context, Map<String, dynamic> programData) {
    String programId = programData['programId'] ?? 'Unnamed Program';
    final String programName = programData['programId'] ?? 'Unnamed Program';
    final int doneDays = int.tryParse(programData['doneDays'].toString()) ?? 0;
    final int totalDays = int.tryParse(programData['totalDays'].toString()) ?? 28;
    final double progress = doneDays / totalDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 24.0),
      decoration: BoxDecoration(
        color: Color(0xFFE6B7FF),
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

          Container(
            margin: const EdgeInsets.only(right: 32.0),
            alignment: Alignment.centerRight,
            child: Text(
              programName,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Row(
            children: [
              Container(

                height: 132,
                width: 132,
                decoration: BoxDecoration(
                  color: Color(0xFFE6B7FF),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  programData['imageUrl'],
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 124.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 56.0,
                        height: 56.0,
                        child: CircularProgressIndicator(
                          value: progress,
                          color: progressColor,
                          backgroundColor: Colors.grey[200],
                          strokeWidth: 8.0,
                        ),
                      ),

                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
