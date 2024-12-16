import 'package:flutter/material.dart';
import 'package:kurs/program/MainPage.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0; // Поточний індекс сторінки

  // Список сторінок
  final List<Widget> _pages = [
    const MainPage(),
    const Center(child: Text("Program Page", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Profile Page", style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Показуємо сторінку відповідно до індексу
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Поточний індекс
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Змінюємо індекс при натисканні
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Program',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}