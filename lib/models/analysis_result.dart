// lib/models/analysis_result.dart

class AnalysisResult {
  final String id;
  final String analysisId;
  final double value;
  final DateTime date;

  AnalysisResult({
    required this.id,
    required this.analysisId,
    required this.value,
    required this.date,
  });

  factory AnalysisResult.fromMap(Map<String, dynamic> map) {
    return AnalysisResult(
      id: map['id'] as String,
      analysisId: map['analysisId'] as String,
      value: (map['value'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'analysisId': analysisId,
      'value': value,
      'date': date.toIso8601String(),
    };
  }
}
