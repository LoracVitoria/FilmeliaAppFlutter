import 'package:flutter/material.dart';
import 'package:flutter_project/filmelia_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filmelia',
      theme: ThemeData(
          primarySwatch: Colors.purple,
          backgroundColor: Colors.white,
          fontFamily: 'Monos'),
      home: const FilmeliaApp(),
    );
  }
}
