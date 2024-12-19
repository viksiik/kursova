import 'package:flutter/material.dart';
import '../components/ButtonField.dart';
import '../components/DialogMessage.dart';
import '../components/Indicator.dart';
import '../components/AddData.dart';
import 'SportPage.dart';

class BirthdayPage extends StatefulWidget {
  const BirthdayPage({
    Key? key,
    this.currentValue = 0,
  }) : super(key: key);

  final int currentValue;

  @override
  _BirthdayPageState createState() => _BirthdayPageState();
}

class _BirthdayPageState extends State<BirthdayPage> {
  final FirestoreHelper firestoreHelper = FirestoreHelper();
  DateTime? _selectedDate;

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6B7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6B7FF),
        flexibleSpace: Center(
          child: Indicator(currentValue: 3),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 100.0, left: 40.0, right: 40.0),
              child: Image.asset(
                'assets/images/birthday_img.png',
                height: 260.0,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Your Birthday",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top:24.0, right: 36.0, left: 36.0),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Select your birthday' // Текст для порожнього поля
                          : _formatDate(_selectedDate!), // Відображення вибраної дати
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: _selectedDate == null ? Colors.grey : Colors.black, // Чорний текст для вибраної дати
                        fontSize: 14.0,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                      size: 20.0,
                    ),
                  ],
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 36.0, left: 40.0, right: 40.0),
              child: ButtonField(
                onTap: () {
                  if (_selectedDate != null) {
                    firestoreHelper.setData(
                      "users",
                      {"Birthday": _selectedDate!.toIso8601String()},
                    );
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => SportLevelPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  } else {
                    ErrorDialog.show(context, 'Please select your birthday.', 'Error');
                  }
                },
                buttonText: "Next",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
