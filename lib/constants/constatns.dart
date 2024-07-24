import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

const double userA = -1.9;
 double userAd = 1;

Color primaryColor(opacity) {
  return Color.fromRGBO(71, 96, 114, opacity);
}

Color secondaryColor(opacity) {
  return Color.fromRGBO(84, 140, 168, opacity);
}
