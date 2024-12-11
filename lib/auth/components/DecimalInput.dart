import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DecimalInput extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const DecimalInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top:24.0),
      padding: const EdgeInsets.symmetric(horizontal: 36.0),
      child: TextField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: <TextInputFormatter>[
          DecimalInputFormatter(), // Використовуємо кастомний фільтр
        ],
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            fillColor: const Color(0xFFFBF4FF),
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
                fontFamily: 'Montserrat'
            )
        ),
      ),
    );
  }
}

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final RegExp regExp = RegExp(r'^\d*(\.\d{0,1})?$');

    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
