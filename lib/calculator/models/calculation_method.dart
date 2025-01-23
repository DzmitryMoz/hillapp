// lib/calculator/models/calculation_method.dart

enum CalculationMethod {
  methodA, // Замените на реальные названия методов
  methodB,
  methodC,
}

extension CalculationMethodExtension on CalculationMethod {
  String get displayName {
    switch (this) {
      case CalculationMethod.methodA:
        return 'Метод A';
      case CalculationMethod.methodB:
        return 'Метод B';
      case CalculationMethod.methodC:
        return 'Метод C';
      default:
        return '';
    }
  }
}
