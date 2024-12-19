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

import 'package:flutter/services.dart';

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
  final TextEditingController _waterGoalController = TextEditingController();
  final TextEditingController _weightGoalController = TextEditingController();

  String _username = '';
  String _waterGoal = '';
  String _weightGoal = '';
  String _startWeight = '';
  String _height = '';
  String _dob = '';
  String _fitnessLevel = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Завантаження даних користувача з Firestore
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
          _username = userData['username'] ?? 'No username';
          _waterGoal = userData['waterGoal']?.toString() ?? '';
          _weightGoal = userData['weightGoal']?.toString() ?? '';
          _startWeight = userData['Weight']?.toString() ?? '';
          _height = userData['Height']?.toString() ?? '';
          _dob = userData['Birthday'] != null
              ? DateTime.parse(userData['Birthday']).toString().split(' ')[0]  // Directly parse string to DateTime
              : '';
          _fitnessLevel = userData['SportLevel'] ?? '';

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
              const SizedBox(height: 4),
              // Поле для вводу імені користувача
              TextField(
                controller: _usernameController,
                obscureText: false,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15), // Обмеження в 15 символів
                ],
                decoration: const InputDecoration(
                  hintText: "Username",
                  labelText: "Username",
                  hintStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Поле для водної цілі
              TextField(
                controller: _waterGoalController,
                obscureText: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _RangeInputFormatter(0, 5000), // Введення від 0 до 5000
                ],
                decoration: const InputDecoration(
                  hintText: "Water Goal (ml)",
                  labelText: "Water Goal (kg)",
                  hintStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Поле для цілі ваги
              TextField(
                controller: _weightGoalController,
                obscureText: false,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  _RangeInputFormatter(0, 300), // Обмеження від 0 до 300
                ],
                decoration: const InputDecoration(
                  hintText: "Weight Goal (kg)",
                  labelText: "Weight Goal (kg)",
                  hintStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Start Weight: ',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,  // Make label bold
                ),
              ),
              Text(
                '$_startWeight kg',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,  // Keep value regular
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Height: ',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,  // Make label bold
                ),
              ),
              Text(
                '$_height cm',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,  // Keep value regular
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Date of Birth: ',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,  // Make label bold
                ),
              ),
              Text(
                '$_dob',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,  // Keep value regular
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Fitness Level: ',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,  // Make label bold
                ),
              ),
              Text(
                '$_fitnessLevel',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,  // Keep value regular
                ),
              ),

              const SizedBox(height: 20),
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


class _RangeInputFormatter extends TextInputFormatter {
  final double min;
  final double max;

  _RangeInputFormatter(this.min, this.max);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      // Дозволяємо стирати всі символи
      return newValue;
    }

    // Регулярний вираз дозволяє лише одну цифру після коми
    final RegExp regex = RegExp(r'^\d*\.?\d{0,1}$');
    if (!regex.hasMatch(newValue.text)) {
      return oldValue; // Якщо введено більше цифр після коми, ігноруємо
    }

    // Перевірка, чи число знаходиться в межах
    try {
      final double? value = double.tryParse(newValue.text);
      if (value == null || value < min || value > max) {
        return oldValue; // Якщо значення не в діапазоні, повертаємо попереднє
      }
    } catch (e) {
      return oldValue; // В разі помилки повертаємо попереднє значення
    }

    return newValue; // Дозволяємо коректне значення
  }
}


