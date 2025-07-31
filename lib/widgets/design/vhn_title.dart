import 'package:flutter/material.dart';

import '../../constants/data.dart';

class VhnTitle extends StatelessWidget {
  final String title;

  const VhnTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black87,
        fontSize: baseSpace * 4,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
