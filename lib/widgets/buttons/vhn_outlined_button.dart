import 'package:flutter/material.dart';

import '../../constants/data.dart';

class VhnOutlinedButton extends StatelessWidget {
  String text;
  final VoidCallback onPress;
  double? fontSize;
  double? padding;

  VhnOutlinedButton({
    Key? key,
    required this.text,
    required this.onPress,
    this.fontSize = null,
    this.padding = null,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: OutlinedButton(
        onPressed: onPress,
        child: Text(
          text,
          style: TextStyle(
            letterSpacing: 2.0,
            fontSize: fontSize != null ? fontSize : baseSpace * 2,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Colors.white70,
          padding: EdgeInsets.all(padding ?? 20.0),
        ),
      ),
    );
  }
}
