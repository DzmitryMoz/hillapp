// lib/calculator/calculator_screen.dart

import 'package:flutter/material.dart';
import 'calculator_model.dart';
import 'calculator_service.dart';
import 'history_log.dart';
import 'educational_resources.dart';
import 'history_service.dart';
import 'user_profile_service.dart';
import 'unit_converter.dart';
import 'schedule_manager.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorService _calculatorService = CalculatorService();
  final HistoryService _historyService = HistoryService();
  final UserProfileService _userProfileService = UserProfileService();
  final UnitConverter _unitConverter = UnitConverter();

  final List<Medication> _medications = [];
  final List<String> _interactionWarnings = [];

  final TextEditingController _medicationNameController = TextEditingController();
  final TextEditingController _medicationDescriptionController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _interactionController = TextEditingController();

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  double _convertedValue = 0.0;
  String _fromUnit = 'ммоль/л';
  String _toUnit = 'мг/дл';

  final _formKey = GlobalKey<FormState>();

  void _addMedication() {
    String name = _medicationNameController.text.trim();
    String description = _medicationDescriptionController.text.trim();
    double? dosage = double.tryParse(_dosageController.text.trim());
    String unit = _unitController.text.trim();
    List<String> interactions = _interactionController.text.trim().isNotEmpty
        ? _interactionController.text.trim().split(',').map((e) => e.trim()).toList()
        : [];

    if (name.isNotEmpty && dosage != null && unit.isNotEmpty) {
      setState(() {
        _medications.add(Medication(
          name: name,
          description: description,
          dosageMg: dosage,
          unit: unit,
          interactions: interactions,
        ));
        _medicationNameController.clear();
        _medicationDescriptionController.clear();
        _dosageController.clear();
        _unitController.clear();
        _interactionController.clear();
      });
    }
  }

  void _setUserProfile() {
    double? weight = double.tryParse(_weightController.text.trim());
    int? age = int.tryParse(_ageController.text.trim());

    if (weight == null || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите корректные данные')),
      );
      return;
    }

    bool kidney = false;
    bool liver = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Настройки профиля'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: kidney,
                      onChanged: (value) {
                        setState(() {
                          kidney = value!;
                        });
                      },
                    ),
                    const Text('Проблемы с почками'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: liver,
                      onChanged: (value) {
                        setState(() {
                          liver = value!;
                        });
                      },
                    ),
                    const Text('Проблемы с печенью'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _userProfileService.setUserProfile(UserProfile(
                    weightKg: weight,
                    age: age,
                    hasKidneyIssues: kidney,
                    hasLiverIssues: liver,
                  ));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Профиль настроен')),
                  );
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        });
      },
    );
  }

  void _calculateDosage() {
    if (_userProfileService.userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, настройте профиль пользователя')),
      );
      return;
    }

    setState(() {
      _interactionWarnings.clear();
      _interactionWarnings.addAll(_calculatorService.checkInteractions(_medications));

      // Добавление логов дозировки
      for (var med in _medications) {
        double dosage = _calculatorService.calculateDosage(
          medication: med,
          userProfile: _userProfileService.userProfile!,
        );
        bool withinLimits = _calculatorService.isDosageWithinLimits(dosage, med);
        if (withinLimits) {
          _addDoseLog(med, dosage);
        }
      }
    });
  }

  void _convertUnits() {
    double? value = double.tryParse(_dosageController.text.trim());
    if (value == null) return;

    double converted = _unitConverter.convert(value, _fromUnit, _toUnit);
    setState(() {
      _convertedValue = converted;
    });
  }

  void _addDoseLog(Medication medication, double dosage) {
    _historyService.addDoseLog(DoseLog(
      medication: medication,
      timestamp: DateTime.now(),
      dosage: dosage,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Калькулятор лекарств'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Дозировка'),
              Tab(text: 'График'),
              Tab(text: 'Взаимодействия'),
              Tab(text: 'Конвертер'),
              Tab(text: 'Образование'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Дозировка
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Добавить лекарство',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: _medicationNameController,
                      decoration:
                      const InputDecoration(labelText: 'Название лекарства'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите название лекарства';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _medicationDescriptionController,
                      decoration:
                      const InputDecoration(labelText: 'Описание'),
                    ),
                    TextFormField(
                      controller: _dosageController,
                      decoration:
                      const InputDecoration(labelText: 'Дозировка (мг)'),
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите дозировку';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Пожалуйста, введите корректное число';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _unitController,
                      decoration:
                      const InputDecoration(labelText: 'Единица измерения'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите единицу измерения';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _interactionController,
                      decoration: const InputDecoration(
                          labelText: 'Взаимодействия (через запятую)'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _addMedication();
                        }
                      },
                      child: const Text('Добавить лекарство'),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    const Text(
                      'Профиль пользователя',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: _weightController,
                      decoration:
                      const InputDecoration(labelText: 'Вес (кг)'),
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите вес';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Пожалуйста, введите корректное число';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _ageController,
                      decoration:
                      const InputDecoration(labelText: 'Возраст (лет)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите возраст';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Пожалуйста, введите корректное число';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _setUserProfile,
                      child: const Text('Настроить профиль'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _calculateDosage,
                      child: const Text('Рассчитать дозировку'),
                    ),
                    const SizedBox(height: 20),
                    if (_userProfileService.userProfile != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Результаты:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ..._medications.map((med) {
                            double dosage = _calculatorService.calculateDosage(
                              medication: med,
                              userProfile:
                              _userProfileService.userProfile!,
                            );
                            bool withinLimits = _calculatorService
                                .isDosageWithinLimits(dosage, med);
                            if (withinLimits) {
                              _addDoseLog(med, dosage);
                            }
                            return ListTile(
                              title: Text(med.name),
                              subtitle: Text(
                                  'Дозировка: ${dosage.toStringAsFixed(2)} ${med.unit}'),
                              trailing: Icon(
                                withinLimits
                                    ? Icons.check_circle
                                    : Icons.warning,
                                color: withinLimits
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          }).toList(),
                          if (_interactionWarnings.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                const Text(
                                  'Взаимодействия:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                ..._interactionWarnings
                                    .map((warning) => Text(warning))
                                    .toList(),
                              ],
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // График
            const ScheduleManager(),
            // Взаимодействия
            HistoryLog(doseLogs: _historyService.doseLogs),
            // Конвертер
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Конвертер единиц',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    decoration:
                    const InputDecoration(labelText: 'Значение'),
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      double? val = double.tryParse(value);
                      if (val != null) {
                        setState(() {
                          _convertedValue =
                              _unitConverter.convert(val, _fromUnit, _toUnit);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _fromUnit,
                          onChanged: (String? newValue) {
                            setState(() {
                              _fromUnit = newValue!;
                              _convertedValue = _unitConverter.convert(
                                  _convertedValue, _fromUnit, _toUnit);
                            });
                          },
                          items: <String>['ммоль/л', 'мг/дл']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const Icon(Icons.arrow_forward),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _toUnit,
                          onChanged: (String? newValue) {
                            setState(() {
                              _toUnit = newValue!;
                              _convertedValue = _unitConverter.convert(
                                  _convertedValue, _fromUnit, _toUnit);
                            });
                          },
                          items: <String>['ммоль/л', 'мг/дл']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Результат: ${_convertedValue.toStringAsFixed(2)} $_toUnit',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // Образование
            const EducationalResources(),
          ],
        ),
      ),
    );
  }
}
