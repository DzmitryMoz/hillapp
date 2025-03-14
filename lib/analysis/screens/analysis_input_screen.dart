// lib/analysis/screens/analysis_input_screen.dart

import 'package:flutter/material.dart';
import '../analysis_service.dart';
import 'analysis_result_screen.dart';
import '../analysis_colors.dart';

class AnalysisInputScreen extends StatefulWidget {
  final String researchId;
  final AnalysisService analysisService;
  final String patientName;
  final int patientAge;
  final String patientSex; // "male" или "female"

  const AnalysisInputScreen({
    Key? key,
    required this.researchId,
    required this.analysisService,
    required this.patientName,
    required this.patientAge,
    required this.patientSex,
  }) : super(key: key);

  @override
  State<AnalysisInputScreen> createState() => _AnalysisInputScreenState();
}

class _AnalysisInputScreenState extends State<AnalysisInputScreen> {
  Map<String, TextEditingController> _controllers = {};
  late List<dynamic> _indicators;

  // Простой метод для перевода пола на русский
  String _translateSex(String sex) {
    if (sex == 'male') {
      return 'Мужской';
    } else if (sex == 'female') {
      return 'Женский';
    }
    // Если в будущем появятся другие варианты - вернём как есть
    return sex;
  }

  @override
  void initState() {
    super.initState();
    // Находим нужное исследование в JSON
    final research = widget.analysisService.findResearchById(widget.researchId);
    if (research == null) {
      _indicators = [];
    } else {
      _indicators = research['indicators'] ?? [];
    }
    // Создаём TextEditingController для каждого показателя
    for (var ind in _indicators) {
      _controllers[ind['id']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  /// Определяем цвет фона (зелёный/красный/белый) в зависимости от норм.
  /// Для показателей с выбором (options) возвращаем подсвеченный фон.
  Color _getBackgroundColor(Map<String, dynamic> indicator) {
    if (indicator.containsKey('options')) {
      final ctrl = _controllers[indicator['id']];
      if (ctrl == null || ctrl.text.trim().isEmpty) return Colors.white;
      final selected = ctrl.text.trim();
      // Для "Цвет мочи"
      if (indicator['id'] == 'color') {
        if (selected == 'Жёлтый' || selected == 'Светло-жёлтый') {
          return Colors.green.shade50;
        } else {
          return Colors.red.shade50;
        }
      }
      // Для "Прозрачность (мутность)"
      if (indicator['id'] == 'clarity') {
        if (selected == 'Прозрачная' || selected == 'Слегка мутная') {
          return Colors.green.shade50;
        } else {
          return Colors.red.shade50;
        }
      }
      return Colors.white;
    }
    final ctrl = _controllers[indicator['id']];
    if (ctrl == null) return Colors.white;
    final textVal = ctrl.text.trim();
    if (textVal.isEmpty) return Colors.white;
    final val = double.tryParse(textVal);
    if (val == null) return Colors.white;
    final status = widget.analysisService.checkValue(
      indicator: indicator,
      value: val,
      sex: widget.patientSex, // "male"/"female"
      age: widget.patientAge,
    );
    if (status.contains('В норме')) {
      return Colors.green.shade50;
    } else if (status.contains('Выше') || status.contains('Ниже')) {
      return Colors.red.shade50;
    }
    return Colors.white;
  }

  /// Собираем введённые результаты и переходим на экран результата
  void _goResult() {
    // 1) Проверяем, что все поля заполнены
    bool allFilled = true;
    for (var ind in _indicators) {
      final id = ind['id'];
      final textVal = _controllers[id]?.text.trim() ?? '';
      if (textVal.isEmpty) {
        allFilled = false;
        break;
      }
    }
    if (!allFilled) {
      // Если хоть одно поле пустое, показываем ошибку и не переходим
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите все данные!')),
      );
      return;
    }

    // 2) Если все поля заполнены, формируем результаты
    final results = <Map<String, dynamic>>[];
    for (var ind in _indicators) {
      final id = ind['id'];
      final name = ind['name'];
      final txt = _controllers[id]?.text.trim() ?? '';
      final val = double.tryParse(txt);
      if (val == null) {
        results.add({
          'id': id,
          'name': name,
          'value': txt,
          'status': 'Некорректное значение',
        });
      } else {
        final status = widget.analysisService.checkValue(
          indicator: ind,
          value: val,
          sex: widget.patientSex,
          age: widget.patientAge,
        );
        results.add({
          'id': id,
          'name': name,
          'value': val,
          'status': status,
        });
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisResultScreen(
          researchId: widget.researchId,
          analysisService: widget.analysisService,
          patientName: widget.patientName,
          patientAge: widget.patientAge,
          patientSex: widget.patientSex,
          results: results,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final research = widget.analysisService.findResearchById(widget.researchId);
    final title = research?['title'] ?? 'Исследование';

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: kMintDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Контейнер с данными пациента
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Имя: ${widget.patientName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Возраст: ${widget.patientAge}, '
                        'Пол: ${_translateSex(widget.patientSex)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Поля ввода для каждого показателя
            for (var ind in _indicators) _buildIndicatorRow(ind),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMintDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Расшифровать'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorRow(Map<String, dynamic> indicator) {
    final ctrl = _controllers[indicator['id']]!;
    final bgColor = _getBackgroundColor(indicator);

    // Получаем нормальный диапазон (если есть)
    final norm = widget.analysisService.getReferenceRange(
      indicator,
      widget.patientSex,
      widget.patientAge,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            indicator['name'] ?? 'Показатель',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // Если у показателя есть список вариантов, показываем dropdown, иначе – TextField
          indicator.containsKey('options')
              ? DropdownButtonFormField<String>(
            value: ctrl.text.isNotEmpty ? ctrl.text : null,
            items: (indicator['options'] as List)
                .map<DropdownMenuItem<String>>((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              ctrl.text = value ?? '';
              setState(() {}); // Обновляем фон при выборе
            },
            decoration: const InputDecoration(
              labelText: 'Выберите значение',
              border: OutlineInputBorder(),
            ),
          )
              : TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Введите значение',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) {
              setState(() {}); // Обновляем фон при изменении значения
            },
          ),
          const SizedBox(height: 4),
          // Если для показателя определён нормальный диапазон и он не является выбором (options)
          if (norm != null && !indicator.containsKey('options'))
            Text('Норма: ${norm[0]} - ${norm[1]}'),
        ],
      ),
    );
  }
}
