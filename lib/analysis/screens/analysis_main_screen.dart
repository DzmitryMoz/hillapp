// lib/analysis/screens/analysis_main_screen.dart

import 'package:flutter/material.dart';
import 'analysis_patient_form.dart';
import 'analysis_history_screen.dart';
import '../analysis_service.dart';
import '../analysis_colors.dart';

class AnalysisMainScreen extends StatefulWidget {
  const AnalysisMainScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisMainScreen> createState() => _AnalysisMainScreenState();
}

class _AnalysisMainScreenState extends State<AnalysisMainScreen> {
  final _analysisService = AnalysisService();
  bool _isLoading = true;
  bool _errorOccurred = false;
  String _errorMessage = '';
  List<dynamic> _researches = [];

  // Предположим, что общий анализ крови (cbc),
  // общий анализ мочи (urinalysis) и биохимия (biochem)
  // доступны и детям, и взрослым:
  final Set<String> _childAndAdultIds = {
    'cbc',
    'biochem',
    'urinalysis',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _analysisService.loadAnalysisData();
      setState(() {
        _researches = _analysisService.getAllResearches();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorOccurred = true;
        _errorMessage = 'Ошибка при загрузке: $e';
        _isLoading = false;
      });
    }
  }

  void _goHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnalysisHistoryScreen()),
    );
  }

  void _selectResearch(Map<String, dynamic> research) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisPatientForm(
          researchId: research['id'],
          analysisService: _analysisService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Расшифровка анализов'),
        backgroundColor: kMintDark,
        actions: [
          IconButton(
            onPressed: _goHistory,
            icon: const Icon(Icons.history),
            tooltip: 'История',
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorOccurred) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // Делим все исследования на 2 группы:
    // 1) childAndAdult  (cbc, biochem, urinalysis)
    // 2) adultOnly
    final childAndAdultList = _researches
        .where((item) => _childAndAdultIds.contains(item['id']))
        .toList();
    final adultOnlyList = _researches
        .where((item) => !_childAndAdultIds.contains(item['id']))
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      children: [
        // --- Блок "Для детей и взрослых" ---
        if (childAndAdultList.isNotEmpty) ...[
          _buildSectionHeader('Для детей и взрослых'),
          const SizedBox(height: 8),
          ...childAndAdultList.map((research) => _buildResearchTile(research)),
          const SizedBox(height: 24),
        ],

        // --- Блок "Только для взрослых" ---
        if (adultOnlyList.isNotEmpty) ...[
          _buildSectionHeader('Только для взрослых'),
          const SizedBox(height: 8),
          ...adultOnlyList.map((research) => _buildResearchTile(research)),
        ],
      ],
    );
  }

  /// Заголовок раздела
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// Виджет для одного элемента списка (контейнер + ListTile)
  Widget _buildResearchTile(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          item['title'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _selectResearch(item),
      ),
    );
  }
}
