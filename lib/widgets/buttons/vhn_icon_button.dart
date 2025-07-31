import 'package:flutter/material.dart';

class VhnIconButton extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color color;
  final void Function() onPressed;

  const VhnIconButton({
    Key? key,
    required this.size,
    required this.icon,
    this.color = Colors.blue,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: size * 2 / 3,
      iconSize: size,
      icon: Icon(
        icon,
        color: color,
      ),
      onPressed: onPressed,
    );
  }
}
