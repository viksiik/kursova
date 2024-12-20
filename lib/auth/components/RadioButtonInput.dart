import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddData.dart';

class RadioButtonInput extends StatefulWidget {
  @override
  _RadioButtonInputState createState() => _RadioButtonInputState();
}

class _RadioButtonInputState extends State<RadioButtonInput> {
  String? _selectedGender;
  final FirestoreHelper firestoreHelper = FirestoreHelper();


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text(
            'Male',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: Radio<String>(
            activeColor: const Color(0xFF8587F8),
            value: 'Male',
            groupValue: _selectedGender,
            onChanged: (String? value) {
              setState(() {
                _selectedGender = value;
              });
              if (_selectedGender != null) {
                firestoreHelper.setData(
                  "users",
                  {"Gender": _selectedGender},
                );
              }
            },
          ),
        ),
        ListTile(
          title: const Text(
            'Female',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: Radio<String>(
            value: 'Female',
            activeColor: const Color(0xFF8587F8),
            groupValue: _selectedGender,
            onChanged: (String? value) {
              setState(() {
                _selectedGender = value;
              });
              if (_selectedGender != null) {
                firestoreHelper.setData(
                  "users",
                  {"Gender": _selectedGender},
                );
              }
            },
          ),
        ),
        ListTile(
          title: const Text(
            'Other',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: Radio<String>(
            value: 'Other',
            activeColor: const Color(0xFF8587F8),
            groupValue: _selectedGender,
            onChanged: (String? value) {
              setState(() {
                _selectedGender = value;
              });
              if (_selectedGender != null) {
                firestoreHelper.setData(
                  "users",
                  {"Gender": _selectedGender},
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
