import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const THEME_STATUS = 'THEME_STATUS';
  bool _darkTheme = false;

  bool get isDarkTheme => _darkTheme;

  ThemeProvider() {
    _loadThemePreference();
  }

  //Method tot toggle
  void toggleTheme() async {
    _darkTheme = !_darkTheme;
    _saveThemePreference();
    notifyListeners();
  }

  Future<void> _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, _darkTheme);
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _darkTheme = pref.getBool(THEME_STATUS) ?? false;
    notifyListeners();
  }
}
