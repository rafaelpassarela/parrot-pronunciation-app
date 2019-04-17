import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {

  CircularButton({this.icon, this.onPressed, this.btnColor = Colors.green});

  final IconData icon;
  final Color btnColor;
  // Callback that fires when the user taps on this widget
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {

    return FloatingActionButton(
      backgroundColor: btnColor,
      onPressed: onPressed,
      child: Icon(icon),
    );

  }



}