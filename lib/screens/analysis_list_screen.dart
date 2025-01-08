// lib/screens/analysis_list_screen.dart

import 'package:flutter/material.dart';
import '../models/analysis.dart';
import '../services/analysis_service.dart';
import 'analysis_decryption_screen.dart';

class AnalysisListScreen extends StatefulWidget {
  const AnalysisListScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisListScreen> createState() => _AnalysisListScreenState();
}

class _AnalysisListScreenState extends State<AnalysisListScreen> {
  final AnalysisService _analysisService = AnalysisService();

  bool _isLoading = true;
  List<Analysis> _analyses = [];

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  Future<void> _loadAnalyses() async {
    await _analysisService.loadAnalyses();
    setState(() {
      _analyses = _analysisService.analyses;
      _isLoading = false;
    });
  }

  void _goToDecryption(Analysis analysis) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisDecryptionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Выберите Анализ'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: _analyses.length,
          itemBuilder: (context, index) {
            final analysis = _analyses[index];
            return ListTile(
              title: Text(analysis.name),
              subtitle: Text(analysis.description),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _goToDecryption(analysis),
            );
          },
        ));
  }
}
