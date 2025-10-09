import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ArticlesPage extends StatelessWidget {
  var articleCount = 20;

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Article Scrollbar")),
      body: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        radius: const Radius.circular(30),
        interactive: true,
        child: ListView.builder(
          itemCount: articleCount,
          
          itemBuilder: (context, index) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(8),
              height: 150,
              color: Colors.blueGrey,
              child: Text(
                'Article $index',
                style: const TextStyle(fontSize: 22),
              ),
            );
          }))
    );
  }
}