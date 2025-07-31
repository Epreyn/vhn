import 'package:flutter/material.dart';

class PopupInputFieldModel {
  String label;
  TextEditingController? textEditingController;
  String placeHolder;

  PopupInputFieldModel({
    required this.label,
    required this.textEditingController,
    required this.placeHolder,
  });
}
