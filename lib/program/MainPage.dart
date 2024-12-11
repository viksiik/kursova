import 'package:flutter/material.dart';

import '../auth/pages/LoginPage.dart';
import 'charts/ActivityChart.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Chart"),
      ),
      body:Container(
      child: SingleChildScrollView(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ActivityChart(),
              ActivityChart(),
            ]
          )
        )
      )
    );
  }
}
