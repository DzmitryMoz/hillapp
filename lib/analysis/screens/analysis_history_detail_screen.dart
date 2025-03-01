// lib/analysis/screens/analysis_history_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../analysis_colors.dart';
import '../db/analysis_history_db.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart'; // Для форматирования даты

class AnalysisHistoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const AnalysisHistoryDetailScreen({Key? key, required this.item})
      : super(key: key);

  @override
  State<AnalysisHistoryDetailScreen> createState() =>
      _AnalysisHistoryDetailScreenState();
}

class _AnalysisHistoryDetailScreenState
    extends State<AnalysisHistoryDetailScreen> {
  // Здесь будет распарсенный JSON из lib/analysis/data/analysis_data.json
  Map<String, dynamic>? _analysisData;

  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }

  /// Загружаем JSON из 'lib/analysis/data/analysis_data.json'.
  /// Если не удаётся загрузить или распарсить — ставим _analysisData = {}
  /// чтобы избежать бесконечного спиннера.
  Future<void> _loadAnalysisData() async {
    try {
      final String jsonString =
      await rootBundle.loadString('lib/analysis/data/analysis_data.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      setState(() {
        _analysisData = data;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке analysis_data.json: $e');
      }
      // Если не загрузилось — укажем пустой Map, чтобы не висеть в спиннере.
      setState(() {
        _analysisData = {};
      });
    }
  }

  /// Удаляем запись по ID, закрываем экран
  Future<void> _deleteAnalysis(BuildContext context) async {
    final id = widget.item['id'];
    if (id is! int) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: некорректный ID')),
      );
      return;
    }
    try {
      final db = AnalysisHistoryDB();
      await db.deleteRecord(id);
      Navigator.pop(context); // Возвращаемся на предыдущий экран
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

  /// Показываем диалог подтверждения удаления
  void _showDeleteDialog(BuildContext context) {
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
              _deleteAnalysis(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Форматируем дату в "dd.MM.yy HH:mm"
  String _formatDate(String dateString) {
    try {
      final dt = DateTime.parse(dateString);
      return DateFormat('dd.MM.yy HH:mm').format(dt);
    } catch (_) {
      return dateString; // если не парсится, выводим как есть
    }
  }

  /// Преобразуем researchId в русское название
  String _getRussianResearchTitle(String researchId) {
    final Map<String, String> russianTitles = {
      'cbc': 'Общий анализ крови',
      'biochem': 'Биохимия',
      'urinalysis': 'Общий анализ мочи',
      // при необходимости добавьте ещё
    };
    return russianTitles[researchId] ?? researchId;
  }

  /// Если надо перевести пол:
  String _translateSex(String sex) {
    if (sex.toLowerCase() == 'male') return 'Мужской';
    if (sex.toLowerCase() == 'female') return 'Женский';
    return sex;
  }

  @override
  Widget build(BuildContext context) {
    final rawDate = widget.item['date'] ?? '';
    final dateFormatted = _formatDate(rawDate);

    final pName = widget.item['patientName'] ?? '';
    final pAge = widget.item['patientAge'] ?? 0;   // int
    final pSexRaw = widget.item['patientSex'] ?? '';
    final pSex = _translateSex(pSexRaw);

    final rId = widget.item['researchId'] ?? '';
    final rTitle = _getRussianResearchTitle(rId);

    final rawResults = widget.item['results'] ?? '';

    // Пробуем распарсить сохранённые результаты (список показателей).
    List<dynamic> parsedResults = [];
    try {
      parsedResults = jsonDecode(rawResults) as List<dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка парсинга results: $e');
      }
    }

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Детали анализа'),
        backgroundColor: kMintDark,
        actions: [
          IconButton(
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: _analysisData == null
      // Пока _analysisData не загружено => спиннер
          ? const Center(child: CircularProgressIndicator())
          : _analysisData!.isEmpty
      // Если _analysisData пуст => была ошибка при загрузке JSON
          ? Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Не удалось загрузить данные для расшифровки.\n'
              'Попробуйте позже.',
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Шапка с основной информацией (центрируем содержимое)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    dateFormatted,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Пациент: $pName, $pAge лет, $pSex',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Исследование: $rTitle',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Если нет показателей или results пустые => выводим ошибку
            if (parsedResults.isEmpty ||
                rawResults.toString().trim().isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Данные не были введены!\n'
                      'Невозможно отобразить расшифровку.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              )
            else
            // Иначе выводим каждый показатель
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: parsedResults.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final resItem =
                  parsedResults[i] as Map<String, dynamic>;
                  return _buildResultCard(
                    resItem,
                    rId,
                    pSexRaw.toString(),
                    (pAge is int) ? pAge : 0,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Построение карточки для одного показателя:
  /// определяем "выше/ниже нормы" и выводим причины/рекомендации.
  Widget _buildResultCard(
      Map<String, dynamic> resItem,
      String researchId,
      String patientSex,
      int patientAge,
      ) {
    final name = resItem['name'] ?? '';
    final indicatorId = resItem['id'];
    final dynamic rawValue = resItem['value'];
    double? value;
    if (rawValue is num) {
      value = rawValue.toDouble();
    }

    // Ищем нужный блок "research" по researchId
    final researches = _analysisData!['researches'] as List;
    final research = researches.firstWhere(
          (r) => r['id'] == researchId,
      orElse: () => null,
    );

    if (research == null) {
      // Не нашли описание?
      return Card(
        child: ListTile(
          title: Text('$name: $rawValue'),
          subtitle: const Text('Не найдено описание в JSON'),
        ),
      );
    }

    // Внутри research находим нужный indicator
    final indicators = research['indicators'] as List;
    final indicator = indicators.firstWhere(
          (ind) => ind['id'] == indicatorId,
      orElse: () => null,
    );

    if (indicator == null) {
      return Card(
        child: ListTile(
          title: Text('$name: $rawValue'),
          subtitle: const Text('Не найдено описание показателя'),
        ),
      );
    }

    // Получаем диапазон норм
    final normalRange = indicator['normalRange'] as Map<String, dynamic>?;
    final range = _findRangeForPatient(normalRange, patientSex, patientAge);
    final double minVal = range[0];
    final double maxVal = range[1];

    // Определяем статус
    String computedStatus = 'В норме';
    String cause = '';
    String recommendation = '';

    if (value != null) {
      if (value < minVal) {
        computedStatus = 'Ниже нормы';
        cause = indicator['causesLower'] ?? '';
        recommendation = indicator['recommendationLower'] ?? '';
      } else if (value > maxVal) {
        computedStatus = 'Выше нормы';
        cause = indicator['causesHigher'] ?? '';
        recommendation = indicator['recommendationHigher'] ?? '';
      }
    }

    return Card(
      child: ListTile(
        title: Text(
          '$name: ${value ?? rawValue}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статус: $computedStatus'),
            Text('Норма: $minVal – $maxVal'),
            if (cause.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Причины: $cause',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            if (recommendation.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Рекомендации: $recommendation',
                style: const TextStyle(color: Colors.blue),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Функция, которая из normalRange достаёт [min, max] с учётом пола/возраста.
  List<double> _findRangeForPatient(
      Map<String, dynamic>? normalRange,
      String sex,
      int age,
      ) {
    if (normalRange == null) {
      return [0, 999999];
    }

    // Упрощённая логика
    if (normalRange.containsKey(sex)) {
      final sexMap = normalRange[sex];
      if (sexMap is Map<String, dynamic>) {
        if (sexMap.containsKey('adult')) {
          return _parseRangeList(sexMap['adult']);
        } else if (sexMap.containsKey('any')) {
          return _parseRangeList(sexMap['any']);
        }
      }
    }

    // Если не нашли, пытаемся 'any'
    if (normalRange.containsKey('any')) {
      return _parseRangeList(normalRange['any']);
    }

    // Если ничего не подошло
    return [0, 999999];
  }

  /// Преобразует массив [мин, макс] к List<double>
  List<double> _parseRangeList(dynamic list) {
    if (list is List && list.length == 2) {
      return [
        (list[0] as num).toDouble(),
        (list[1] as num).toDouble(),
      ];
    }
    return [0, 999999];
  }
}
