// lib/services/history_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/analysis_result.dart';

class HistoryService {
  Database? _database;

  Future<void> init() async {
    try {
      _database = await openDatabase(
        join(await getDatabasesPath(), 'history_database.db'),
        onCreate: (db, version) {
          return db.execute(
            '''
            CREATE TABLE analysis_history(
              id TEXT PRIMARY KEY,
              analysisId TEXT,
              value REAL,
              date TEXT
            )
            ''',
          );
        },
        version: 1,
      );
      print('База данных инициализирована');
    } catch (e) {
      print('Ошибка при инициализации базы данных: $e');
      throw Exception('Не удалось инициализировать базу данных');
    }
  }

  Future<void> addAnalysisResult(AnalysisResult result) async {
    final db = _database;
    if (db == null) {
      print('База данных не инициализирована');
      throw Exception('База данных не инициализирована');
    }

    try {
      await db.insert(
        'analysis_history',
        result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Результат анализа добавлен в базу данных: ${result.toMap()}');
    } catch (e) {
      print('Ошибка при добавлении результата анализа: $e');
      throw Exception('Не удалось добавить результат анализа');
    }
  }

  Future<List<AnalysisResult>> getAllHistory() async {
    final db = _database;
    if (db == null) {
      print('База данных не инициализирована');
      throw Exception('База данных не инициализирована');
    }

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'analysis_history',
        orderBy: 'date DESC',
      );

      List<AnalysisResult> results = List.generate(maps.length, (i) {
        return AnalysisResult.fromMap(maps[i]);
      });

      print('История анализов загружена: ${results.length} записей');
      return results;
    } catch (e) {
      print('Ошибка при загрузке истории анализов: $e');
      throw Exception('Не удалось загрузить историю анализов');
    }
  }
}
