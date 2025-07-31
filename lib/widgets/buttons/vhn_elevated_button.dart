import 'package:flutter/material.dart';

import '../../constants/data.dart';

class VhnElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPress;
  double? fontSize;
  Color? color;
  Color? textColor;

  VhnElevatedButton({
    Key? key,
    required this.text,
    required this.onPress,
    fontSize,
    this.color,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          letterSpacing: 2.0,
          fontSize: fontSize == null ? fontSize : baseSpace * 2,
          color: textColor ?? null,
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(baseSpace * 2.5),
        backgroundColor: color ?? null,
      ),
    );
  }
}
