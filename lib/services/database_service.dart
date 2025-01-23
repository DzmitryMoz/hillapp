// lib/services/database_service.dart

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_input.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'hillapp.db');
    return await openDatabase(
      path,
      version: 2, // Увеличьте версию базы данных
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // Добавьте метод onUpgrade
      onOpen: (db) async {
        print('База данных успешно открыта');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE analysis_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userName TEXT,
        age INTEGER,
        weight REAL,
        researchId TEXT,
        results TEXT,
        date TEXT
      )
    ''');
    print('Таблица analysis_history успешно создана');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Если вы увеличили версию базы данных, добавьте необходимые изменения
      await db.execute('''
        CREATE TABLE IF NOT EXISTS analysis_history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userName TEXT,
          age INTEGER,
          weight REAL,
          researchId TEXT,
          results TEXT,
          date TEXT
        )
      ''');
      print('Таблица analysis_history обновлена или создана');
    }
  }

  Future<void> insertAnalysis(UserInput userInput, String researchId) async {
    try {
      final db = await database;
      await db.insert(
        'analysis_history',
        {
          'userName': userInput.userName,
          'age': userInput.age,
          'weight': userInput.weight,
          'researchId': researchId, // Убедитесь, что здесь 'researchId'
          'results': json.encode(userInput.userResults),
          'date': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Результаты анализа успешно сохранены в базе данных');
    } catch (e) {
      print('Ошибка при сохранении результатов анализа: $e');
      throw Exception('Ошибка при сохранении результатов анализа: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllAnalyses() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query('analysis_history', orderBy: 'date DESC');
      print('Получено ${results.length} записей из базы данных');
      return results;
    } catch (e) {
      print('Ошибка при получении истории анализов: $e');
      throw Exception('Ошибка при получении истории анализов: $e');
    }
  }
}
