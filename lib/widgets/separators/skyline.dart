import 'package:flutter/material.dart';

class SkyLine extends StatelessWidget {
      SkyLine(
      {
        Key? key,
        required this.w,
        required this.h,
        this.color = Colors.black,
      }
      ) : super(key: key);


  double w;
  double h;
  Color color;

  @override
  Widget build(BuildContext context) {
    return   SizedBox(
      width: w,
      height: h,
      child: Container(
        color: color,
      ),
    );
  }
}
