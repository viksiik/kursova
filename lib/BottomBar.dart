import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex; // Поточний індекс
  final ValueChanged<int> onTap; // Функція для обробки натискання

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color(0XFF8587F8),
      currentIndex: currentIndex, // Поточний індекс
      onTap: onTap, // Обробка натискання
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '',

        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '',
        ),
      ],
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.black87,
      unselectedItemColor: Colors.white70,
    );
  }
}
