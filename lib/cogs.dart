import 'package:flutter/material.dart';

class CogsPage extends StatefulWidget {
  const CogsPage({super.key});

  @override
  _CogsPageState createState() => _CogsPageState();
}

class _CogsPageState extends State<CogsPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("You're a cog in the machine")
      ),
    );
  }
}