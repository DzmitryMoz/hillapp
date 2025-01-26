// lib/analysis/db/analysis_history_db.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'; // Для kDebugMode (логирование)

class AnalysisHistoryDB {
  static final AnalysisHistoryDB _instance = AnalysisHistoryDB._internal();
  factory AnalysisHistoryDB() => _instance;
  AnalysisHistoryDB._internal();

  Database? _database;

  /// Создаём или получаем базу
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('analysis_history.db');
    return _database!;
  }

  Future<Database> _initDB(String file) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, file);

    if (kDebugMode) {
      print('Инициализация базы: $path');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    if (kDebugMode) {
      print('Создаём таблицу history (если не существует)');
    }
    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        patientName TEXT,
        patientAge INTEGER,
        patientSex TEXT,
        researchId TEXT,
        results TEXT
      )
    ''');
  }

  /// Получить все записи
  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final db = await database;
    try {
      // ВАЖНО: "SELECT * FROM" (с пробелом)
      const query = 'SELECT * FROM history ORDER BY date DESC';
      if (kDebugMode) {
        print('Выполняем запрос: $query');
      }
      return await db.rawQuery(query);
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка getAllRecords: $e');
      }
      rethrow;
    }
  }

  /// Вставить запись
  Future<int> insertRecord(Map<String, dynamic> record) async {
    final db = await database;
    try {
      if (kDebugMode) {
        print('Вставляем запись: $record');
      }
      return await db.insert('history', record);
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка insertRecord: $e');
      }
      rethrow;
    }
  }

  /// Удалить запись по id
  Future<int> deleteRecord(int id) async {
    final db = await database;
    try {
      if (kDebugMode) {
        print('Удаляем запись id=$id');
      }
      return await db.delete(
        'history',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка deleteRecord: $e');
      }
      rethrow;
    }
  }
}
