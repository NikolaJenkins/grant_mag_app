import 'package:flutter/material.dart';
import 'package:grant_mag_app/settings.dart';

class ThemeModel extends ChangeNotifier{
  ThemeLabels? _theme = ThemeLabels.ocean;
  ThemeLabels? get ThemeLabel => _theme;

  void changeTheme(ThemeLabels? newValue) {
    _theme = newValue;
    notifyListeners();
  }
}