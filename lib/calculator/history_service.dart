// lib/calculator/history_service.dart

import 'calculator_model.dart';

class HistoryService {
  final List<DoseLog> _doseLogs = [];

  List<DoseLog> get doseLogs => _doseLogs;

  void addDoseLog(DoseLog log) {
    _doseLogs.add(log);
  }
}
