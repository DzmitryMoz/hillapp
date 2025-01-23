// lib/models/health_data.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Measurement {
  final DateTime date;
  final double systolic;
  final double diastolic;
  final double heartRate;

  Measurement({
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
    };
  }

  factory Measurement.fromMap(Map<String, dynamic> map) {
    return Measurement(
      date: DateTime.parse(map['date']),
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      heartRate: map['heartRate'],
    );
  }
}

class HealthData extends ChangeNotifier {
  final List<Measurement> _measurements = [];

  List<Measurement> get measurements => List.unmodifiable(_measurements);

  Measurement? get latestMeasurement =>
      _measurements.isNotEmpty ? _measurements.last : null;

  HealthData() {
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    final prefs = await SharedPreferences.getInstance();
    final String? measurementsString = prefs.getString('measurements');
    if (measurementsString != null) {
      final List<dynamic> decoded = jsonDecode(measurementsString);
      _measurements.addAll(decoded.map((e) => Measurement.fromMap(e)).toList());
      notifyListeners();
    }
  }

  Future<void> _saveMeasurements() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
    jsonEncode(_measurements.map((e) => e.toMap()).toList());
    await prefs.setString('measurements', encoded);
  }

  void addMeasurement(Measurement measurement) {
    _measurements.add(measurement);
    notifyListeners();
    _saveMeasurements();
  }

  void deleteMeasurement(int index) {
    if (index >= 0 && index < _measurements.length) {
      _measurements.removeAt(index);
      notifyListeners();
      _saveMeasurements();
    }
  }

  void deleteAllMeasurements() {
    _measurements.clear();
    notifyListeners();
    _saveMeasurements();
  }
}
