// lib/services/support_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/support_ticket.dart';

class SupportService {
  Database? _database;

  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'support_database.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE support_tickets(
            id TEXT PRIMARY KEY,
            userId TEXT,
            subject TEXT,
            message TEXT,
            timestamp TEXT
          )
          ''',
        );
      },
      version: 1,
    );
  }

  Future<void> insertTicket(SupportTicket ticket) async {
    final db = _database;
    if (db == null) return;

    await db.insert(
      'support_tickets',
      ticket.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Добавьте методы для получения и обработки тикетов по необходимости
}
