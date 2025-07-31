import 'package:flutter/material.dart';

class HeaderData extends StatelessWidget {

   String data;
      HeaderData(
      {
        Key? key,
        required this.data

      }
      ) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Text(data,
        style: TextStyle(fontWeight: FontWeight.bold));
  }
}
