import 'package:flutter/material.dart';

const kMdpInputDecoration = InputDecoration(
  fillColor: Colors.white,
  border: OutlineInputBorder(),
  labelText: 'Mot de Passe',
  hintText: 'Mot de Passe',
  suffixIcon: Icon(
    Icons.remove_red_eye,
  ),
  prefixIcon: Icon(
    Icons.lock,
  ),
);

const kMailInputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(),
  labelText: 'Adresse Mail',
  prefixIcon: Icon(
    Icons.mail_outline,
  ),
);
