import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {

  CircularButton({this.icon, this.onPressed, this.btnColor = Colors.green, this.enabled = true});

  final IconData icon;
  final Color btnColor;
  // Callback that fires when the user taps on this widget
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {

    return FloatingActionButton(
      backgroundColor: (enabled) ? btnColor : Colors.black38,
      onPressed: (enabled) ? onPressed : null,
      child: Icon(icon),
    );

  }



}