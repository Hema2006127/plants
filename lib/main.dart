
import 'package:flutter/material.dart';
import 'onboarding.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  static var width;
  static var height;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnBoardingScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Home Screen",
          style: TextStyle(fontSize: 100),
        ),
      ),
    );
  }
}