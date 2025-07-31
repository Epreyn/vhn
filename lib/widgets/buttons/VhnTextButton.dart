import 'package:flutter/material.dart';

class VhnTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final double padding;
  final double fontSize;
  final void Function() onPressed;

  const VhnTextButton({
    Key? key,
    required this.text,
    this.icon = Icons.all_inclusive,
    required this.padding,
    required this.fontSize,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: TextButton(
        onPressed: onPressed,
        child: icon != Icons.all_inclusive
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon),
                    SizedBox(width: padding),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                  ),
                ),
              ),
      ),
    );
  }
}
