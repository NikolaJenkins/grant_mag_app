import 'package:flutter/material.dart';
import 'package:grant_mag_app/settings.dart';

class SettingsModel extends ChangeNotifier{
  ThemeLabels? _theme = ThemeLabels.ocean;
  ThemeLabels? get ThemeLabel => _theme;
  double _textSize = 50;
  double get TextSize => _textSize;

  void changeTheme(ThemeLabels? newValue) {
    _theme = newValue;
    notifyListeners();
  }

  void changeTextSize(double newTextSize) {
    _textSize = newTextSize;
    notifyListeners();
  }
}