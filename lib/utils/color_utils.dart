// lib/utils/color_utils.dart

import 'package:flutter/material.dart';
import '../calculator/models/calendar_medication_intake.dart';

Color getIntakeTypeColor(IntakeType type) {
  switch (type) {
    case IntakeType.morning:
      return Colors.blueAccent;
    case IntakeType.evening:
      return Colors.green;
    case IntakeType.single:
      return Colors.orange;
    case IntakeType.course:
      return Colors.purple;
    default:
      return Colors.grey;
  }
}
