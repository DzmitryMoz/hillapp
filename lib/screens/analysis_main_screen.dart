// lib/screens/analysis_main_screen.dart

import 'package:flutter/material.dart';
import '../services/research_service.dart';
import '../models/research.dart';
import 'analysis_user_info_screen.dart';

class AnalysisMainScreen extends StatefulWidget {
  const AnalysisMainScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisMainScreen> createState() => _AnalysisMainScreenState();
}

class _AnalysisMainScreenState extends State<AnalysisMainScreen> {
  final ResearchService _researchService = ResearchService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResearches();
  }

  Future<void> _loadResearches() async {
    try {
      await _researchService.loadResearches();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Не удалось загрузить виды исследований.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _navigateToUserInfo(Research research) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisUserInfoScreen(research: research),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите исследование'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _researchService.researches.length,
        itemBuilder: (context, index) {
          final research = _researchService.researches[index];
          return ListTile(
            title: Text(research.title),
            subtitle: Text(research.description),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _navigateToUserInfo(research),
          );
        },
      ),
    );
  }
}
