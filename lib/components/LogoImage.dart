import 'package:flutter/material.dart';

class LogoImage extends StatelessWidget {
  final String imagePath;
  Function()? onTap;

  LogoImage({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          height: 64,
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.only(top: 36.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Image.asset(imagePath),
        ),
      ),
    );
  }
}