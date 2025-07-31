import 'package:flutter/material.dart';

class CardRow extends StatelessWidget {
  String label;
  String? text;
  String? sigle;

  CardRow({Key? key, required this.label, required this.text, this.sigle = null}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        Text(
          sigle != null
              ? '${text!} ${sigle}'
              : text != null
                  ? text!
                  : '',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
