import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserActivityScreen extends StatefulWidget {
  @override
  _UserActivityScreenState createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, int> activityCount = {
    'abs': 0,
    'lower_body': 0,
    'full_body': 0,
  };

  @override
  void initState() {
    super.initState();
    getUserActivities();
  }

  Future<Map<String, dynamic>> getUserActivities() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("No authenticated user found.");
    }

    try {
      // Отримуємо всі документи з підколекції Activity
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser?.uid)
          .collection('Activity')
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        print("Processing Document ID: ${doc.id}");
        print("Document Data: $data");

        // Оновлюємо підсумки активностей
        setState(() {
          if (data.containsKey('abs')) {
            activityCount['abs'] =
                activityCount['abs']! + (data['abs'] as num).toInt();
          }
          if (data.containsKey('lower_body')) {
            activityCount['lower_body'] =
                activityCount['lower_body']! + (data['lower_body'] as num).toInt();
          }
          if (data.containsKey('full_body')) {
            activityCount['full_body'] =
                activityCount['full_body']! + (data['full_body'] as num).toInt();
          }
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    return {
      'abs': activityCount['abs'],
      'lower_body': activityCount['lower_body'],
      'full_body': activityCount['full_body'],
    };

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Activity Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Abs Count: ${activityCount['abs']}'),
            Text('Lower Body Count: ${activityCount['lower_body']}'),
            Text('Full Body Count: ${activityCount['full_body']}'),
          ],
        ),
      ),
    );
  }
}
