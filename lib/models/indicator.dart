// lib/models/indicator.dart

class Indicator {
  final String id;
  final String name;
  final String unit;
  final double normalMin;
  final double normalMax;

  Indicator({
    required this.id,
    required this.name,
    required this.unit,
    required this.normalMin,
    required this.normalMax,
  });

  factory Indicator.fromMap(Map<String, dynamic> map) {
    return Indicator(
      id: map['id'] as String,
      name: map['name'] as String,
      unit: map['unit'] as String,
      normalMin: (map['normalMin'] as num).toDouble(),
      normalMax: (map['normalMax'] as num).toDouble(),
    );
  }
}
