// lib/analysis/screens/analysis_history_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert'; // для jsonDecode
import '../db/analysis_history_db.dart';
import '../analysis_colors.dart';
import 'analysis_history_detail_screen.dart';

class AnalysisHistoryScreen extends StatefulWidget {
  const AnalysisHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState extends State<AnalysisHistoryScreen> {
  bool _isLoading = true;
  List<Map<String,dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final db = AnalysisHistoryDB();
    final rows = await db.getAllRecords();
    setState(() {
      _records = rows;
      _isLoading = false;
    });
  }

  void _openDetailScreen(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisHistoryDetailScreen(item: item),
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
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        itemBuilder: (ctx, i) {
          final item = _records[i];
          return _buildHistoryItem(item);
        },
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final date = item['date'] ?? '';
    final pName = item['patientName'] ?? '';
    final pAge = item['patientAge']?.toString() ?? '';
    final pSex = item['patientSex'] ?? '';
    final rId = item['researchId'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0,2),
          )
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text('Дата: $date', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Пациент: $pName, $pAge лет, $pSex\nИсследование: $rId'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openDetailScreen(item),
      ),
    );
  }
}
