// lib/analysis/db/analysis_history_db.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnalysisHistoryDB {
  static final AnalysisHistoryDB _instance = AnalysisHistoryDB._internal();
  factory AnalysisHistoryDB() => _instance;

  AnalysisHistoryDB._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('analysis_history.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE AnalysisHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        patientName TEXT,
        patientSex TEXT,
        patientAge INTEGER,
        researchId TEXT,
        results TEXT
      )
    ''');
  }

  Future<int> insertRecord(Map<String,dynamic> record) async {
    final db = await database;
    return await db.insert('AnalysisHistory', record);
  }

  Future<List<Map<String,dynamic>>> getAllRecords() async {
    final db = await database;
    return await db.query('AnalysisHistory', orderBy: 'id DESC');
  }

// Можно добавить методы удаления / очистки и т.д.
}
