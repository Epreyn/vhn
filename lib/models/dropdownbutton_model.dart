import 'package:flutter/material.dart';

class DropDownButtonModel {
  String? hint;
  List<String> items;
  String? initialValue;
  Icon? icon;

  final void Function(String?) onChanged;

  DropDownButtonModel(
      {required this.hint, required this.items, required this.initialValue, required this.onChanged, this.icon = null});
}
