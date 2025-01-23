// lib/calculator/models/form_type.dart

enum FormType {
  tablet,
  syrup,
  injection,
}

extension FormTypeExtension on FormType {
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
