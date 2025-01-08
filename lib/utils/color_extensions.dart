// lib/utils/color_extensions.dart
import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color darken([double percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final f = 1 - percent / 100;
    return withRed((red * f).round())
        .withGreen((green * f).round())
        .withBlue((blue * f).round());
  }
}
