import 'dart:io';
import 'dart:convert'; // Для роботи з Base64
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kurs/auth/components/ButtonField.dart';
import 'package:kurs/auth/components/InputField.dart';

import '../BottomBar.dart';
import '../auth/components/DialogMessage.dart';
import '../program/MainPage.dart';
import '../workouts/WorkoutPage.dart';
import 'LogoutButton.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  int _currentIndex = 2;
  final currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _waterGoalController = TextEditingController();
  final TextEditingController _weightGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Завантажити дані користувача
  void _loadUserData() async {
    if (currentUser == null) {
      print("No authenticated user found.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(currentUser?.uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _usernameController.text = userData['username'] ?? 'No username';
          _waterGoalController.text = userData['waterGoal']?.toString() ?? '';
          _weightGoalController.text = userData['weightGoal']?.toString() ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Вивести дані перед оновленням
      print("Updating user data:");
      print("Username: ${_usernameController.text}");
      print("WaterGoal: ${_waterGoalController.text}");
      print("WeightGoal: ${_weightGoalController.text}");

      await _firestore.collection('users').doc(currentUser?.uid).update({
        'username': _usernameController.text,
        'waterGoal': int.tryParse(_waterGoalController.text) ?? 0,
        'weightGoal': double.tryParse(_weightGoalController.text) ?? 0.0,
      });

      ErrorDialog.show(context, 'Successfully updated info.', 'Success');
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainWorkoutPage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> signOut() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      await _auth.signOut();
      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFFF),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 48.0),
              const Text(
                'User Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 4),
              // Поле для вводу імені користувача
              InputField(
                controller: _usernameController,
                hintText: 'Username',
                obscureText: false,
              ),

              SizedBox(height: 4),

              InputField(
                controller: _waterGoalController,
                hintText: 'Water Goal (ml)',
                obscureText: false,
              ),
              SizedBox(height: 4),
              // Поле для цілі ваги
              InputField(
                controller: _weightGoalController,
                hintText: 'Weight Goal (kg)',
                obscureText: false,
              ),
              SizedBox(height: 20),
              ButtonField(onTap: _updateUserProfile, buttonText: 'Save Profile'),
              LogoutButton()
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
