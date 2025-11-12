import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color? _selectedOption;  

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                color: Colors.blue,
                child: ListTile(
                  leading: Text('Theme'),
                  trailing: DropdownButton<Color>(
                    value: _selectedOption,
                    hint: const Text('Choose'),
                    items: ColorLabel.colorLabels.map((ColorLabel entry) {
                      return DropdownMenuItem<Color>(
                        value: entry.color,
                        child: Text(entry.label),
                      );
                    }).toList(),
                    onChanged: (Color? newValue) {
                      setState(() {
                        _selectedOption = newValue;
                      });
                    },
                  )
                )
                )
            ],
          )
        )
      )
    );
  }
}

enum ColorLabel{

  blue(label: 'Blue', color: Colors.blue),
  pink(label: 'Pink', color: Colors.pink),
  green(label: 'Green', color: Colors.green),
  orange(label: 'Orange', color: Colors.orange),
  grey(label: 'Grey', color: Colors.grey);

  const ColorLabel({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  static List<ColorLabel> get colorLabels => values.map<ColorLabel>((color) => color).toList();
}