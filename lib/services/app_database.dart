// lib/services/app_database.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  /// Возвращает единственную (синглтон) открытую базу.
  static Future<Database> getInstance() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Создаём таблицу Users, если не создана
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');
      },
      onOpen: (db) async {
        // На случай, если БД уже существует, но таблицы нет:
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  /// Закрыть БД, если это когда-то потребуется
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
