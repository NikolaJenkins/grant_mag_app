import 'package:flutter/material.dart';

class ColorThemeModel extends ChangeNotifier{
  Color? _colorTheme = Colors.blue;
  Color? get colorTheme => _colorTheme;

  void changeColorTheme(Color? newValue) {
    _colorTheme = newValue;
    notifyListeners();
  }
}