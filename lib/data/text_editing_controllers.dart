import 'package:flutter/material.dart';

// CONTROLLERS POUR LES VINS
Map<String, TextEditingController> wineEditingControllers = {
  'cuvee': TextEditingController(),
  'vintage': TextEditingController(),
  'packaging': TextEditingController(),
  'format': TextEditingController(),
  'priceCHR': TextEditingController(),
  'priceCellarMan': TextEditingController(),
  'quantity': TextEditingController(),
};

// CONTROLLERS POUR LES UTILISATEURS
Map<String, TextEditingController> userEditingControllers = {
  'company': TextEditingController(),
  'department': TextEditingController(),
  'telephone': TextEditingController(),
  'address': TextEditingController(),
  'postalCode': TextEditingController(),
  'city': TextEditingController(),
  'status': TextEditingController(),
};
