import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_calculator/home_screen.dart';
import 'package:smart_calculator/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !_isDarkMode;

    setState(() {
      _isDarkMode = newValue;
    });

    await prefs.setBool('isDarkMode', newValue);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Calculator',
      //themeMode: themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: CalculatorApp(
        theme: _isDarkMode ? CalculatorTheme.dark : CalculatorTheme.light,
        onToggleTheme: _toggleTheme,
        isDark: _isDarkMode,
      ),
    );
  }
}
