import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  CircularButton({
      this.name,
      this.icon,
      this.onPressed,
      this.btnColor = Colors.green,
      this.enabled = true,
      this.size
  });

  final String name;
  final IconData icon;
  final Color btnColor;
  // Callback that fires when the user taps on this widget
  final VoidCallback onPressed;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: name,
      backgroundColor: (enabled) ? btnColor : Colors.black38,
      onPressed: (enabled) ? onPressed : null,
      child: Icon(
        icon,
        size: size,
      ),
    );
  }
}
