import 'package:flutter/material.dart';

class ErrorDialog {
  static void show(BuildContext context, String errorMessage, String typeMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            typeMessage,
            style: TextStyle(
              fontSize: 24.0,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              color: Colors.red,
            ),
          ),
          content: Text(
            errorMessage,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 12.0,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
