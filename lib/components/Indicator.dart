import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final int currentValue;
  final int totalButtons;

  const Indicator({
    required this.currentValue,
    this.totalButtons = 5,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            totalButtons,
                (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: AnimatedContainer(
                curve: Curves.easeIn,
                duration: const Duration(milliseconds: 500),
                width: index == currentValue ? 40 : 15,
                height: 15,
                decoration: BoxDecoration(
                  color: Color(0xFFFBF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
