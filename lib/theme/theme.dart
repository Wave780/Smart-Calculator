import 'package:flutter/material.dart';

class CalculatorTheme {
  final Color backgroundColor;
  final Color displayColor;
  final Color numberButtonColor;
  final Color operationButtonColor;
  final Color textColor;

  const CalculatorTheme({
    required this.backgroundColor,
    required this.displayColor,
    required this.numberButtonColor,
    required this.operationButtonColor,
    required this.textColor,
  });

  static const CalculatorTheme dark = CalculatorTheme(
    backgroundColor: Colors.black,
    displayColor: Colors.white,
    numberButtonColor: Color(0xFF333333),
    operationButtonColor: Colors.orange,
    textColor: Colors.white,
  );

  static const CalculatorTheme light = CalculatorTheme(
    backgroundColor: Colors.white,
    displayColor: Colors.black,
    numberButtonColor: Color(0xFFF0F0F0),
    operationButtonColor: Colors.blue,
    textColor: Colors.black,
  );
}
