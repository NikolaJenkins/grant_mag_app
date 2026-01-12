
import 'package:flutter/material.dart';
import 'package:grant_mag_app/settings_model.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  double _textSize = 20;
  bool year2023 = true;

  @override 
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, value, child) => Scaffold(
      appBar: AppBar(title: const Text("Settings",),
                    backgroundColor: value.ThemeLabel!.headerColor,),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                color: value.ThemeLabel!.shelfColor,
                child: ListTile(
                  leading: Text('Theme'),
                  trailing: DropdownButton<ThemeLabels>(
                    value: value.ThemeLabel,
                    hint: const Text('Choose'),
                    items: ThemeLabels.ThemeLabel.map((ThemeLabels entry) {
                      return DropdownMenuItem<ThemeLabels>(
                        value: entry,
                        child: Text(entry.label),
                      );
                    }).toList(),
                    onChanged: (ThemeLabels? newValue) {
                      final colorThemeChooser = context.read<SettingsModel>();
                      colorThemeChooser.changeTheme(newValue);
                    },
                  )
                ),
                ),
              Container(
                color: value.ThemeLabel!.shelfColor,
                child: ListTile(
                  title: Text('Text Size'),
                  subtitle: Slider(
                    year2023: year2023,
                    value: _textSize,
                    max: 50,
                    min: 10,
                    divisions: 10,
                    label: _textSize.round().toString(),
                    onChanged: (double newValue) {
                      // final textSizeChooser = context.read<SettingsModel>();
                      // textSizeChooser.changeTextSize(newValue);
                      setState(() {
                        _textSize = newValue;
                      });
                    }
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

enum ThemeLabels{

  ocean(label: 'Ocean', 
        headerColor: Colors.blue, 
        backgroundColor: Colors.blueAccent, 
        shelfColor: Colors.lightBlue),
  barbie(label: 'Barbie', 
        headerColor: Colors.pink,
        backgroundColor: Colors.pinkAccent,
        shelfColor: Color.fromARGB(255, 146, 2, 88)),
  forest(label: 'Forest', 
        headerColor: Colors.green,
        backgroundColor: Colors.lightGreen,
        shelfColor: Color.fromARGB(255, 2, 78, 5)
        ),
  sunset(label: 'Sunset', 
        headerColor: Color.fromARGB(211, 255, 163, 51),
        backgroundColor: Color.fromARGB(255, 211, 113, 15),
        shelfColor: Colors.deepOrange
        ),
  night(label: 'Night', 
        headerColor: Colors.deepPurple,
        backgroundColor: Color.fromARGB(255, 42, 40, 40),
        shelfColor: Color.fromARGB(255, 85, 86, 87)
        );

  const ThemeLabels({
    required this.label,
    required this.headerColor,
    required this.backgroundColor,
    required this.shelfColor,
  });

  final String label;
  final Color headerColor;
  final Color backgroundColor;
  final Color shelfColor;

  static List<ThemeLabels> get ThemeLabel => values.map<ThemeLabels>((color) => color).toList();
}