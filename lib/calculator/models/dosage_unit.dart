// lib/calculator/models/dosage_unit.dart

enum DosageUnit {
  mgPerKg,
  mcg,
  g,
}

extension DosageUnitExtension on DosageUnit {
  String get displayName {
    switch (this) {
      case DosageUnit.mgPerKg:
        return 'мг/кг';
      case DosageUnit.mcg:
        return 'мкг';
      case DosageUnit.g:
        return 'г';
    }
  }
}
