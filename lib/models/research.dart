// lib/models/research.dart

import 'indicator.dart';

class Research {
  final String id;
  final String title;
  final String description;
  final List<Indicator> indicators;

  Research({
    required this.id,
    required this.title,
    required this.description,
    required this.indicators,
  });

  factory Research.fromMap(Map<String, dynamic> map) {
    return Research(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      indicators: List<Indicator>.from(
        map['indicators'].map((ind) => Indicator.fromMap(ind)),
      ),
    );
  }
}
