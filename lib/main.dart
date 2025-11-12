import 'package:flutter/material.dart';
import 'package:grant_mag_app/rss.dart';

void main() {
  print('test');
  runApp(new HomeApp(),);
  print('runsapp');
}

class HomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Grant Mag RSS Test',
    home: new GrantMagRSS(),
   );
  }
}

