import 'package:flutter/material.dart';

String stringValueChecker(String? value, String defaultValue) {
  String result;

  if(value! != null) {
    result = value;
  } else {
    result = defaultValue;
  }

  return result;
}