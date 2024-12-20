import 'package:flutter/material.dart';

import '../../main.dart';
import '../DaysPage.dart';

class ProgramCard extends StatelessWidget {
  final String title;
  final String year;
  final String imageUrl;
  final String gradColor;
  final VoidCallback? onTap;

  const ProgramCard({
    super.key,
    required this.title,
    required this.year,
    required this.imageUrl,
    required this.gradColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color startColor = Color(int.parse('0xFF$gradColor'));
    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage(imageUrl),
          fit: BoxFit.fill,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [startColor.withOpacity(0.6), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  year,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
