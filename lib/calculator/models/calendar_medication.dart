// lib/calculator/models/calendar_medication.dart

enum DosageUnit { mgPerKg, mcg, g }
enum FormType { tablet, syrup, injection }
enum AdministrationRoute { oral, intravenous, intramuscular }

extension DosageUnitExtension on DosageUnit {
  String toShortString() => toString().split('.').last;

  static DosageUnit fromString(String value) {
    switch (value) {
      case 'mgPerKg':
        return DosageUnit.mgPerKg;
      case 'mcg':
        return DosageUnit.mcg;
      case 'g':
        return DosageUnit.g;
      default:
        return DosageUnit.mgPerKg;
    }
  }

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

extension FormTypeExtension on FormType {
  String toShortString() => toString().split('.').last;

  static FormType fromString(String value) {
    switch (value) {
      case 'tablet':
        return FormType.tablet;
      case 'syrup':
        return FormType.syrup;
      case 'injection':
        return FormType.injection;
      default:
        return FormType.tablet;
    }
  }

  String get displayName {
    switch (this) {
      case FormType.tablet:
        return 'Таблетка';
      case FormType.syrup:
        return 'Сироп';
      case FormType.injection:
        return 'Инъекция';
    }
  }
}

extension AdministrationRouteExtension on AdministrationRoute {
  String toShortString() => toString().split('.').last;

  static AdministrationRoute fromString(String value) {
    switch (value) {
      case 'oral':
        return AdministrationRoute.oral;
      case 'intravenous':
        return AdministrationRoute.intravenous;
      case 'intramuscular':
        return AdministrationRoute.intramuscular;
      default:
        return AdministrationRoute.oral;
    }
  }

  String get displayName {
    switch (this) {
      case AdministrationRoute.oral:
        return 'Перорально';
      case AdministrationRoute.intravenous:
        return 'Внутривенно';
      case AdministrationRoute.intramuscular:
        return 'Внутримышечно';
    }
  }
}

class CalendarMedication {
  final String id;
  final String name;
  final String dosage;
  final DosageUnit dosageUnit;
  final FormType formType;
  final AdministrationRoute administrationRoute;

  CalendarMedication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.dosageUnit,
    required this.formType,
    required this.administrationRoute,
  });

  factory CalendarMedication.fromMap(Map<String, dynamic> map) {
    return CalendarMedication(
      id: map['id'] as String,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      dosageUnit: DosageUnitExtension.fromString(map['dosageUnit'] as String),
      formType: FormTypeExtension.fromString(map['formType'] as String),
      administrationRoute:
      AdministrationRouteExtension.fromString(map['administrationRoute'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'dosageUnit': dosageUnit.toShortString(),
      'formType': formType.toShortString(),
      'administrationRoute': administrationRoute.toShortString(),
    };
  }
}
