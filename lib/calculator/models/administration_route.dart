// lib/calculator/models/administration_route.dart

enum AdministrationRoute {
  oral,
  intravenous,
  intramuscular,
}

extension AdministrationRouteExtension on AdministrationRoute {
  String get displayName {
    switch (this) {
      case AdministrationRoute.oral:
        return 'Пероральный';
      case AdministrationRoute.intravenous:
        return 'Внутривенный';
      case AdministrationRoute.intramuscular:
        return 'Внутримышечный';
    }
  }
}
