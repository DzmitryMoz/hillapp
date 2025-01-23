// lib/calculator/services/calendar_database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

import '../models/calendar_medication.dart';
import '../models/calendar_medication_intake.dart';

class CalendarDatabaseService {
  // Singleton
  static final CalendarDatabaseService _instance = CalendarDatabaseService._internal();
  factory CalendarDatabaseService() => _instance;
  CalendarDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> loadMedications() async {
    await getAllCalendarMedications(); // Просто вызываем метод для инициализации
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hillapp_calendar.db');
    debugPrint('Инициализация календарной базы данных: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    debugPrint('Создание календарных таблиц ...');

    // Таблица для календарных препаратов
    await db.execute('''
      CREATE TABLE calendar_medications(
        id TEXT PRIMARY KEY,
        name TEXT,
        dosage TEXT,
        dosageUnit TEXT,
        formType TEXT,
        administrationRoute TEXT
      )
    ''');

    // Таблица для приёмов препаратов
    await db.execute('''
      CREATE TABLE calendar_medication_intakes(
        id TEXT PRIMARY KEY,
        medicationId TEXT,
        day TEXT,
        time TEXT,
        intakeType TEXT,
        FOREIGN KEY (medicationId) REFERENCES calendar_medications(id) ON DELETE CASCADE
      )
    ''');

    debugPrint('Календарные таблицы созданы.');
  }

  // ----------------- Методы для работы с CalendarMedication --------------------

  Future<void> insertCalendarMedication(CalendarMedication medication) async {
    try {
      final db = await database;
      await db.insert(
        'calendar_medications',
        medication.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Календарный препарат добавлен: ${medication.name}, id: ${medication.id}');
    } catch (e) {
      debugPrint('Ошибка при добавлении календарного препарата: $e');
    }
  }

  Future<CalendarMedication?> getCalendarMedicationByName(String name) async {
    final db = await database;
    final maps = await db.query(
      'calendar_medications',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (maps.isEmpty) {
      debugPrint('Календарный препарат с названием "$name" не найден.');
      return null;
    }
    final m = maps.first;
    debugPrint('Найден календарный препарат: ${m['name']} (ID: ${m['id']})');
    return CalendarMedication.fromMap(m);
  }

  // ----------------- Методы для работы с CalendarMedicationIntake --------------------

  Future<void> insertCalendarMedicationIntake(CalendarMedicationIntake intake) async {
    try {
      final db = await database;
      await db.insert(
        'calendar_medication_intakes',
        intake.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Календарный прием препарата добавлен: ${intake.toMap()}');
    } catch (e) {
      debugPrint('Ошибка при добавлении календарного приема препарата: $e');
    }
  }

  Future<void> deleteCalendarMedicationIntake(String intakeId) async {
    try {
      final db = await database;
      await db.delete(
        'calendar_medication_intakes',
        where: 'id = ?',
        whereArgs: [intakeId],
      );
      debugPrint('Календарный прием препарата с id $intakeId удален.');
    } catch (e) {
      debugPrint('Ошибка при удалении календарного приема препарата: $e');
    }
  }

  Future<List<CalendarMedicationIntake>> getMedicationsForDay(DateTime day) async {
    final db = await database;
    final dayString = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final maps = await db.query(
      'calendar_medication_intakes',
      where: 'day = ?',
      whereArgs: [dayString],
      orderBy: 'time ASC', // Сортировка по времени
    );
    debugPrint('Записей в calendar_medication_intakes для $dayString: ${maps.length}');
    return maps.map((map) => CalendarMedicationIntake.fromMap(map)).toList();
  }

  Future<List<CalendarMedication>> getAllCalendarMedications() async {
    final db = await database;
    final maps = await db.query('calendar_medications');
    debugPrint('Найдено календарных препаратов: ${maps.length}');
    return maps.map((map) => CalendarMedication.fromMap(map)).toList();
  }
}
