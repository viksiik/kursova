import 'package:flutter/material.dart';

class ButtonField extends StatelessWidget {

  final Function()? onTap;
  final String buttonText;

  const ButtonField({
    super.key,
    required this.onTap,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        margin: const EdgeInsets.only(top: 25.0, left: 32.0, right: 32.0),
        decoration: BoxDecoration(
            color: const Color(0xFF8587F8),
            borderRadius: BorderRadius.circular(24.0),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ),
    );
  }
}