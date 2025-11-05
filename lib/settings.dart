import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  ColorEntry? _selectedOption;  

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
                  trailing: DropdownButton<ColorEntry>(
                    value: _selectedOption,
                    hint: const Text('Choose'),
                    items: ColorEntry.map((ColorLabel entry) {
                      return DropdownMenuItem<Color>(
                        value: entry.color,
                        child: Text(entry.label),
                      );
                    }
                    ),
                    onChanged: (ColorEntry? newValue) {
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

typedef ColorEntry = DropdownMenuEntry<ColorLabel>;

// enum ColorLabel {
//     blue('Blue', Colors.blue),
//     purple('Purple', Colors.purple),

//     const ColorLabel(this.label, this.color);
//     final String label;
//     final Color color;

//     static final List<ColorEntry> entries = UnmodifiableListView<ColorEntry>(
//       values.map<ColorEntry>(
//         (ColorLabel color) => ColorEntry(
//           value: color,
//           label: color.label,
//           enabled: color.label != 'Grey',
//           style: MenuItemButton.styleFrom(foregroundColor: color.color),
//         )
//       )
//     )
//   }
enum ColorLabel {

  blue('Blue', Colors.blue),
  pink('Pink', Colors.pink),
  green('Green', Colors.green),
  yellow('Orange', Colors.orange),
  grey('Grey', Colors.grey);

  const ColorLabel(this.label, this.color);
  final String label;
  final Color color;

  static final List<ColorLabel> colorLabels = UnmodifiableListView<ColorLabel>(
    values.map<ColorLabel>((color) => color).toList(),
  );
}