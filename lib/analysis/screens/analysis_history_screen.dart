// lib/analysis/screens/analysis_history_screen.dart

import 'package:flutter/material.dart';
import '../analysis_colors.dart';
import '../db/analysis_history_db.dart';
import 'analysis_history_detail_screen.dart';
import 'package:flutter/foundation.dart';

class AnalysisHistoryScreen extends StatefulWidget {
  const AnalysisHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState extends State<AnalysisHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final db = AnalysisHistoryDB();
    try {
      final rows = await db.getAllRecords();
      if (kDebugMode) {
        print('Получено записей: ${rows.length}');
      }
      setState(() {
        _records = rows;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке истории: $e');
      }
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке: $e')),
      );
    }
  }

  Future<void> _deleteRecord(BuildContext context, int id) async {
    try {
      final db = AnalysisHistoryDB();
      await db.deleteRecord(id);
      await _loadRecords();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Анализ удалён')),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при удалении: $e')),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить анализ'),
        content: const Text('Вы уверены, что хотите удалить этот анализ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteRecord(context, id);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('История анализов'),
        backgroundColor: kMintDark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? const Center(child: Text('Нет сохранённых анализов'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final item = _records[i];
          return _buildHistoryItem(item);
        },
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final id = item['id'];
    final date = item['date'] ?? '';
    final pName = item['patientName'] ?? '';
    final pSex = item['patientSex'] ?? '';
    final pAge = item['patientAge']?.toString() ?? '';
    final rId = item['researchId'] ?? '';

    return Card(
      child: ListTile(
        title: Text(
          'Дата: $date',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Пациент: $pName, $pAge лет, $pSex\nИсследование: $rId'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnalysisHistoryDetailScreen(item: item),
            ),
          ).then((_) {
            // Перезагрузим список, если вдруг запись удалили
            _loadRecords();
          });
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            if (id is int) {
              _showDeleteDialog(context, id);
            }
          },
        ),
      ),
    );
  }
}