// lib/models/analysis.dart

class Analysis {
  final String id;
  final String name;
  final String description;
  final String unit;
  final double normalMin;
  final double normalMax;
  final List<String> possibleConditions;

  Analysis({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.normalMin,
    required this.normalMax,
    required this.possibleConditions,
  });

  factory Analysis.fromMap(Map<String, dynamic> map) {
    return Analysis(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      unit: map['unit'] as String,
      normalMin: (map['normalMin'] as num).toDouble(),
      normalMax: (map['normalMax'] as num).toDouble(),
      possibleConditions: List<String>.from(map['possibleConditions'] as List),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unit': unit,
      'normalMin': normalMin,
      'normalMax': normalMax,
      'possibleConditions': possibleConditions,
    };
  }
}
