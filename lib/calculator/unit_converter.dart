// lib/calculator/unit_converter.dart

import 'calculator_service.dart';

class UnitConverter {
  final CalculatorService _calculatorService = CalculatorService();

  double convert(double value, String fromUnit, String toUnit) {
    return _calculatorService.convertUnits(value, fromUnit, toUnit);
  }
}
