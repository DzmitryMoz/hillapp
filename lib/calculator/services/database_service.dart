// lib/calculator/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Модели
import '../models/calculation_history.dart';
import '../models/user_data.dart';
import '../models/medication.dart';
import '../models/medication_intake.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  // Реализация Singleton
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hillapp.db');
    debugPrint('Инициализация базы данных: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('Создание таблиц ...');

    await db.execute('''
      CREATE TABLE calculation_history(
        id TEXT PRIMARY KEY,
        medicationId TEXT,
        medicationName TEXT,
        age INTEGER,
        weight REAL,
        calculatedDose REAL,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE medications(
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        standardDosePerKg REAL,
        maxDose REAL,
        minAge REAL,
        maxAge REAL,
        dosageUnit TEXT,
        formType TEXT,
        administrationRoute TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE medication_intakes(
        id TEXT PRIMARY KEY,
        day TEXT,
        medicationId TEXT,
        name TEXT,
        dosage TEXT,
        dosageUnit TEXT,
        formType TEXT,
        administrationRoute TEXT,
        intakeType TEXT,
        time TEXT
      )
    ''');
    debugPrint('Таблицы созданы.');
  }

  // --------------------- Методы для CalculationHistory ---------------------

  /// Сохранение истории в таблицу calculation_history
  Future<void> insertHistory(CalculationHistory history) async {
    final db = await database;
    await db.insert(
      'calculation_history',
      {
        'id': history.id,
        'medicationId': history.medicationId,
        'medicationName': history.medicationName,
        'age': history.userData.age,
        'weight': history.userData.weight,
        'calculatedDose': history.calculatedDose,
        'date': history.date.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('История добавлена: ${history.id}');
  }

  /// Получение всех записей из calculation_history
  Future<List<CalculationHistory>> getAllHistories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('calculation_history');
    debugPrint('Найдено историй: ${maps.length}');

    return maps.map((map) {
      return CalculationHistory(
        id: map['id'],
        medicationId: map['medicationId'],
        medicationName: map['medicationName'],
        userData: UserData(
          age: map['age'],
          weight: (map['weight'] as num).toDouble(),
        ),
        calculatedDose: (map['calculatedDose'] as num).toDouble(),
        date: DateTime.parse(map['date']),
      );
    }).toList();
  }

  // --------------------- Методы для Medications ---------------------

  Future<void> insertMedication(Medication medication) async {
    try {
      final db = await database;
      await db.insert(
        'medications',
        medication.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Препарат добавлен: ${medication.name}, id: ${medication.id}');
    } catch (e) {
      debugPrint('Ошибка при добавлении препарата: $e');
    }
  }

  Future<Medication?> getMedicationByName(String name) async {
    final db = await database;
    final maps = await db.query(
      'medications',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (maps.isEmpty) {
      debugPrint('Препарат "$name" не найден.');
      return null;
    }
    final m = maps.first;
    debugPrint('Найден препарат: ${m['name']} (ID: ${m['id']})');
    return Medication.fromMap(m);
  }

  // --------------------- Методы для MedicationIntake ---------------------

  Future<void> insertMedicationIntake(MedicationIntake intake) async {
    try {
      final db = await database;
      await db.insert(
        'medication_intakes',
        intake.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Прием препарата добавлен: ${intake.toMap()}');
    } catch (e) {
      debugPrint('Ошибка при добавлении приема препарата: $e');
    }
  }

  Future<List<MedicationIntake>> getMedicationsForDay(DateTime day) async {
    final db = await database;
    final dayString = day.toIso8601String().split('T').first;
    final maps = await db.query(
      'medication_intakes',
      where: 'day = ?',
      whereArgs: [dayString],
    );
    debugPrint('Записей в medication_intakes для $dayString: ${maps.length}');
    return maps.map((map) => MedicationIntake.fromMap(map)).toList();
  }
}
