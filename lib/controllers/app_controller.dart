import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tryon_ai/utils/constants.dart';
import 'package:tryon_ai/utils/extensions.dart';

class AppController extends ChangeNotifier {
  AppController() {
    final darkMode = Hive.userBox.get(preferDarkModeKey) ?? false;
    setTheme(darkMode);
  }
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void setTheme(bool value) {
    _isDarkMode = value;
    Hive.userBox.put(preferDarkModeKey, value);
    notifyListeners();
  }
}
