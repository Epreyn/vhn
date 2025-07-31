import 'package:flutter/material.dart';

double dynamicColumnOfDataTable(context) {
  double columnWith;
  double screenWidth = MediaQuery.of(context).size.width;

  screenWidth > 900 ? columnWith = 850 : columnWith = screenWidth;

  return columnWith;
}
