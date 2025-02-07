// lib/calendar/models/calendar_medication.dart

import 'package:flutter/material.dart';

/// --------------------
/// Единицы дозировки (на русском)
/// --------------------
enum DosageUnit {
  kapli,   // Капли (gtt.)
  ml,      // мл
  mg,      // мг
  g,       // г
  sht,     // штуки (таблетки, капсулы, дражже...)
  porc,    // пакетики/порции
  cm,      // сантиметры (для кремов, мазей)
  pshik,   // «пшики» (дозы аэрозоля)
  lozhka,  // ложки (чайные/столовые)
}

/// Расширение для вывода единиц дозировки на русском
extension DosageUnitExtension on DosageUnit {
  String get displayName {
    switch (this) {
      case DosageUnit.kapli:
        return 'Капли (gtt.)';
      case DosageUnit.ml:
        return 'мл';
      case DosageUnit.mg:
        return 'мг';
      case DosageUnit.g:
        return 'г';
      case DosageUnit.sht:
        return 'шт.';
      case DosageUnit.porc:
        return 'пакетики (порции)';
      case DosageUnit.cm:
        return 'см (при выдавливании)';
      case DosageUnit.pshik:
        return 'пшики (дозы)';
      case DosageUnit.lozhka:
        return 'ложки';
    }
  }
}

/// --------------------
/// Формы выпуска (на русском)
/// --------------------
enum FormType {
  kapli,        // Капли (gtt.)
  nastoika,     // Настойка (мл)
  nastoi,       // Настои (мл)
  sirop,        // Сироп (мл/ложки)
  suspenziya,   // Суспензия (мл)
  emulsiya,     // Эмульсия (мл)
  kapsula,      // Капсула (капс.)
  tabletka,     // Таблетка (таб.)
  poroshok,     // Порошки (г / порции)
  granuly,      // Гранулы (г / саше)
  draje,        // Драже (шт.)
  krem,         // Крем (г/см)
  maz,          // Мазь (г/см)
  gel,          // Гель (г/см)
  suppozitorii, // Суппозитории (супп.)
  pasta,        // Паста (г/см)
  aerozoli,     // Аэрозоли (пшики/мл)
}

/// Расширение для вывода формы выпуска на русском
extension FormTypeExtension on FormType {
  String get displayName {
    switch (this) {
      case FormType.kapli:
        return 'Капли (gtt.)';
      case FormType.nastoika:
        return 'Настойка (мл)';
      case FormType.nastoi:
        return 'Настои (мл)';
      case FormType.sirop:
        return 'Сироп (мл/ложки)';
      case FormType.suspenziya:
        return 'Суспензия (мл)';
      case FormType.emulsiya:
        return 'Эмульсия (мл)';
      case FormType.kapsula:
        return 'Капсула (капс.)';
      case FormType.tabletka:
        return 'Таблетка (таб.)';
      case FormType.poroshok:
        return 'Порошок (г/порции)';
      case FormType.granuly:
        return 'Гранулы (г/саше)';
      case FormType.draje:
        return 'Драже (шт.)';
      case FormType.krem:
        return 'Крем (г/см)';
      case FormType.maz:
        return 'Мазь (г/см)';
      case FormType.gel:
        return 'Гель (г/см)';
      case FormType.suppozitorii:
        return 'Суппозитории (супп.)';
      case FormType.pasta:
        return 'Паста (г/см)';
      case FormType.aerozoli:
        return 'Аэрозоли (пшики/мл)';
    }
  }
}

/// --------------------
/// Путь введения (на русском)
/// --------------------
enum AdministrationRoute {
  oral,             // Перорально
  intravenous,      // Внутривенно
  intramuscular,    // Внутримышечно
  intrathecal,      // Интратекально
  subcutaneous,     // Подкожно
  sublingual,       // Сублингвально
  transbuccal,      // Трансбуккально
  rectal,           // Ректально
  vaginal,          // Вагинально
  intranasal,       // Интраназально
  inhalation,       // Ингаляционно
  transdermal,      // Трансдермально
  topical,          // Наружно
  intradermal,      // Внутрикожно
  intracardiac,     // Внутрисердечно
  intracavernous,   // Внутрикавернозно
}

/// Расширение для удобного вывода пути введения на русском
extension AdministrationRouteExtension on AdministrationRoute {
  String get displayName {
    switch (this) {
      case AdministrationRoute.oral:
        return 'Перорально';
      case AdministrationRoute.intravenous:
        return 'Внутривенно';
      case AdministrationRoute.intramuscular:
        return 'Внутримышечно';
      case AdministrationRoute.intrathecal:
        return 'Интратекально';
      case AdministrationRoute.subcutaneous:
        return 'Подкожно';
      case AdministrationRoute.sublingual:
        return 'Сублингвально';
      case AdministrationRoute.transbuccal:
        return 'Трансбуккально';
      case AdministrationRoute.rectal:
        return 'Ректально';
      case AdministrationRoute.vaginal:
        return 'Вагинально';
      case AdministrationRoute.intranasal:
        return 'Интраназально';
      case AdministrationRoute.inhalation:
        return 'Ингаляционно';
      case AdministrationRoute.transdermal:
        return 'Трансдермально';
      case AdministrationRoute.topical:
        return 'Наружно';
      case AdministrationRoute.intradermal:
        return 'Внутрикожно';
      case AdministrationRoute.intracardiac:
        return 'Внутрисердечно';
      case AdministrationRoute.intracavernous:
        return 'Внутрикавернозно';
    }
  }
}

/// --------------------
/// Класс CalendarMedication
/// --------------------
class CalendarMedication {
  final String id;
  final String name;        // Название препарата
  final String dosage;      // Количество (дозировка)
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

  /// Сериализация в Map (например, для сохранения в БД)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'dosageUnit': dosageUnit.toString().split('.').last,
      'formType': formType.toString().split('.').last,
      'administrationRoute': administrationRoute.toString().split('.').last,
    };
  }

  /// Десериализация из Map (например, при загрузке из БД)
  factory CalendarMedication.fromMap(Map<String, dynamic> map) {
    return CalendarMedication(
      id: map['id'] as String,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      dosageUnit: _dosageUnitFromString(map['dosageUnit'] as String),
      formType: _formTypeFromString(map['formType'] as String),
      administrationRoute: _routeFromString(map['administrationRoute'] as String),
    );
  }

  /// copyWith – удобное обновление полей
  CalendarMedication copyWith({
    String? name,
    String? dosage,
    DosageUnit? dosageUnit,
    FormType? formType,
    AdministrationRoute? administrationRoute,
  }) {
    return CalendarMedication(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      formType: formType ?? this.formType,
      administrationRoute: administrationRoute ?? this.administrationRoute,
    );
  }

  /// Вспомогательные методы парсинга (для fromMap)
  static DosageUnit _dosageUnitFromString(String value) {
    return DosageUnit.values.firstWhere(
          (e) => e.toString().split('.').last == value,
      orElse: () => DosageUnit.mg,
    );
  }

  static FormType _formTypeFromString(String value) {
    return FormType.values.firstWhere(
          (e) => e.toString().split('.').last == value,
      orElse: () => FormType.tabletka,
    );
  }

  static AdministrationRoute _routeFromString(String value) {
    return AdministrationRoute.values.firstWhere(
          (e) => e.toString().split('.').last == value,
      orElse: () => AdministrationRoute.oral,
    );
  }
}
