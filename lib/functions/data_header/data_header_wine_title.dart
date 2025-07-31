import 'package:flutter/material.dart';

DataColumn dataHeaderWineTitle(
    String title, int columnIndex, setState, orderType, descending) {
  return DataColumn(
    label: InkWell(
      onTap: () {
        setState(() {
          switch (columnIndex) {
            case 0:
              orderType = 'cuvee';
              descending = !descending;
              break;
            case 1:
              orderType = 'vintage';
              descending = !descending;
              break;
            case 2:
              orderType = 'color';
              descending = !descending;
              break;
            case 3:
              orderType = 'format';
              descending = !descending;
              break;
            case 4:
              orderType = 'quantity';
              descending = !descending;
              break;
          }
        });
      },
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          letterSpacing: 1,
          wordSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
