import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grant_mag_app/color_theme_model.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {

  @override 
  Widget build(BuildContext context) {
    return Consumer<ColorThemeModel>(
      builder: (context, value, child) => Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                color: value.colorTheme,
                child: ListTile(
                  leading: Text('Theme'),
                  trailing: DropdownButton<Color>(
                    value: value.colorTheme, // figure out provider stuff??
                    hint: const Text('Choose'),
                    items: ColorLabel.colorLabels.map((ColorLabel entry) {
                      return DropdownMenuItem<Color>(
                        value: entry.color,
                        child: Text(entry.label),
                      );
                    }).toList(),
                    onChanged: (Color? newValue) {
                      final colorThemeChooser = context.read<ColorThemeModel>();

                      colorThemeChooser.changeColorTheme(newValue);
                    },
                  )
                )
                )
            ],
          )
        )
      )
    ),
    );
  }
}

enum ColorLabel{

  blue(label: 'Blue', color: Colors.blue),
  pink(label: 'Pink', color: Colors.pink),
  green(label: 'Green', color: Colors.green),
  orange(label: 'Orange', color: Colors.orange),
  grey(label: 'Gray', color: Colors.grey); // change the spelling

  const ColorLabel({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  static List<ColorLabel> get colorLabels => values.map<ColorLabel>((color) => color).toList();
}