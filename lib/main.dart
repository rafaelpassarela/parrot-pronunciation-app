import 'package:flutter/material.dart';
import 'package:parrot_pronunciation_app/home/home.state.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of our application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parrot',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(title: 'Parrot Home Page'),
    );
  }
}
