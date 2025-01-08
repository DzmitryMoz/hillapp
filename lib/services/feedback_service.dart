// lib/services/feedback_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/feedback.dart';

class FeedbackService {
  Database? _database;

  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'feedback_database.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE feedback(
            id TEXT PRIMARY KEY,
            userId TEXT,
            analysisId TEXT,
            comment TEXT,
            rating INTEGER,
            timestamp TEXT
          )
          ''',
        );
      },
      version: 1,
    );
  }

  Future<void> insertFeedback(FeedbackModel feedback) async {
    final db = _database;
    if (db == null) return;

    await db.insert(
      'feedback',
      feedback.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FeedbackModel>> getFeedbackForAnalysis(String analysisId) async {
    final db = _database;
    if (db == null) return [];

    final List<Map<String, dynamic>> maps = await db.query(
      'feedback',
      where: 'analysisId = ?',
      whereArgs: [analysisId],
    );

    return List.generate(maps.length, (i) {
      return FeedbackModel.fromMap(maps[i]);
    });
  }
}
