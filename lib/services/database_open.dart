// lib/services/database_open.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> openAppDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'users.db');

  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
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
      // Если БД уже существует, но таблицы нет — создаём
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
}
