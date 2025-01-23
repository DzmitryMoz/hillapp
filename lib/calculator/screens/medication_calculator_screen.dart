// lib/calculator/screens/medication_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/medication.dart';
import '../models/dosage_unit.dart';
import '../models/form_type.dart';
import '../models/administration_route.dart';
import '../models/calculation_history.dart';
import '../models/user_data.dart';
import '../models/calculation_method.dart'; // Импорт CalculationMethod
import '../services/medication_service.dart';
import '../services/calculation_service.dart';
import '../services/database_service.dart';
import '../widgets/calculation_method_selector.dart'; // Импорт виджета

class MedicationCalculatorScreen extends StatefulWidget {
  const MedicationCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<MedicationCalculatorScreen> createState() =>
      _MedicationCalculatorScreenState();
}

class _MedicationCalculatorScreenState
    extends State<MedicationCalculatorScreen> {
  final MedicationService _medicationService = MedicationService();
  final CalculationService _calculationService = CalculationService();
  final DatabaseService _databaseService = DatabaseService();

  // Шаги
  int _currentStep = 0;

  // Выбранный препарат
  Medication? _selectedMedication;
  bool _isManualEntry = false;

  // Форма для ручного ввода
  final _manualFormKey = GlobalKey<FormState>();
  String _manualName = '';
  String _manualDosage = '';
  DosageUnit _manualDosageUnit = DosageUnit.mgPerKg;
  FormType _manualFormType = FormType.tablet;
  AdministrationRoute _manualAdministrationRoute = AdministrationRoute.oral;

  // Поля для второго шага (вес и возраст, например)
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Результаты вычислений
  double? _calculatedDose;
  bool _isDoseValid = true;
  String? _errorMessage;

  // Выбранный метод расчёта
  CalculationMethod? _selectedCalculationMethod;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    // Загружаем список препаратов из JSON (или откуда нужно)
    await _medicationService.loadMedications();
    setState(() {});
  }

  // Шаги вперёд / назад
  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  // Сброс формы
  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _selectedMedication = null;
      _isManualEntry = false;
      _manualName = '';
      _manualDosage = '';
      _manualDosageUnit = DosageUnit.mgPerKg;
      _manualFormType = FormType.tablet;
      _manualAdministrationRoute = AdministrationRoute.oral;
      _weightController.clear();
      _ageController.clear();
      _calculatedDose = null;
      _isDoseValid = true;
      _errorMessage = null;
      _selectedCalculationMethod = null;
    });
  }

  // Шаг 3: расчёт
  void _calculateDose() {
    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final age = double.tryParse(_ageController.text.trim()) ?? 0.0;

    if (weight <= 0 || age <= 0) {
      setState(() {
        _isDoseValid = false;
        _errorMessage = 'Введите корректные возраст и вес.';
      });
      return;
    }
    if (_selectedMedication == null) {
      setState(() {
        _isDoseValid = false;
        _errorMessage = 'Препарат не выбран.';
      });
      return;
    }
    if (_selectedCalculationMethod == null) {
      setState(() {
        _isDoseValid = false;
        _errorMessage = 'Метод расчёта не выбран.';
      });
      return;
    }
    try {
      final dose = weight * (_selectedMedication!.standardDosePerKg);
      bool isValid = dose <= _selectedMedication!.maxDose;
      setState(() {
        _calculatedDose = dose;
        _isDoseValid = isValid;
        _errorMessage = isValid
            ? 'Проверяйте правильность введенных данных.'
            : 'Дозировка превышает максимальную допустимую.';
      });

      // Сохраняем историю расчёта (пример)
      final history = CalculationHistory(
        id: const Uuid().v4(),
        medicationId: _selectedMedication!.id,
        medicationName: _selectedMedication!.name,
        userData: UserData(age: age.toInt(), weight: weight),
        calculatedDose: dose,
        date: DateTime.now(),
      );
      _databaseService.insertHistory(history);
    } catch (e) {
      setState(() {
        _isDoseValid = false;
        _errorMessage = 'Ошибка при расчёте: $e';
      });
    }
  }

  // Шаги контента
  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
      // Шаг 0: выбор препарата
        return Column(
          children: [
            const Text(
              'Выберите или введите препарат',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_medicationService.medications.isEmpty) ...[
              const Text('Пока нет доступных препаратов.'),
            ] else ...[
              DropdownButtonFormField<Medication>(
                decoration: const InputDecoration(
                  labelText: 'Список препаратов',
                  border: OutlineInputBorder(),
                ),
                items: _medicationService.medications.map((med) {
                  return DropdownMenuItem<Medication>(
                    value: med,
                    child: Text(med.name),
                  );
                }).toList(),
                value: _selectedMedication,
                onChanged: (val) {
                  setState(() {
                    _selectedMedication = val;
                    _isManualEntry = false;
                  });
                },
                validator: (val) {
                  if (val == null && !_isManualEntry) {
                    return 'Пожалуйста, выберите препарат или добавьте вручную';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isManualEntry = true;
                  _selectedMedication = null;
                });
              },
              child: const Text('Добавить препарат вручную'),
            ),
            if (_isManualEntry) ...[
              const SizedBox(height: 16),
              _buildManualEntryForm(),
            ],
          ],
        );

      case 1:
      // Шаг 1: выбор метода расчёта
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Выберите метод расчёта',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CalculationMethodSelector(
              onMethodSelected: (method) {
                setState(() {
                  _selectedCalculationMethod = method;
                });
              },
            ),
            if (_selectedCalculationMethod == null && _errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        );

      case 2:
      // Шаг 2: ввод веса и возраста
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Введите вес и возраст пациента',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Вес (кг)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Пожалуйста, введите вес';
                }
                final weight = double.tryParse(val);
                if (weight == null || weight <= 0) {
                  return 'Пожалуйста, введите корректный вес';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Возраст (лет)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Пожалуйста, введите возраст';
                }
                final age = double.tryParse(val);
                if (age == null || age <= 0) {
                  return 'Пожалуйста, введите корректный возраст';
                }
                return null;
              },
            ),
            if (_errorMessage != null && !_isDoseValid)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        );

      case 3:
      // Шаг 3: результат расчёта
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _calculateDose,
              child: const Text('Рассчитать'),
            ),
            const SizedBox(height: 16),
            if (_calculatedDose != null)
              Text(
                'Расчётная доза: $_calculatedDose',
                style: const TextStyle(fontSize: 18),
              ),
            if (!_isDoseValid && _errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  // Нажатие на «Далее»
  void _onContinue() {
    if (_currentStep == 0) {
      if (_isManualEntry) {
        // Проверяем форму
        if (_manualFormKey.currentState?.validate() ?? false) {
          _manualFormKey.currentState?.save();
          // Создаём новый препарат
          final newMed = Medication(
            id: const Uuid().v4(),
            name: _manualName,
            description: '',
            standardDosePerKg: 0.0, // При желании можно вводить
            maxDose: 9999.0, // или тоже вводить вручную
            minAge: 0.0,
            maxAge: 150.0,
            dosageUnit: _manualDosageUnit,
            formType: _manualFormType,
            administrationRoute: _manualAdministrationRoute,
          );
          // Добавляем в список и выбираем
          _medicationService.addManualMedication(newMed);
          setState(() {
            _selectedMedication = newMed;
            _isManualEntry = false;
          });
          _nextStep();
        } else {
          // Форма невалидна
        }
      } else {
        // Если не ручной ввод, проверяем, выбран ли препарат
        if (_selectedMedication == null) {
          setState(() {
            _errorMessage = 'Не выбран препарат из списка.';
          });
        } else {
          setState(() {
            _errorMessage = null;
          });
          _nextStep();
        }
      }
    } else if (_currentStep == 1) {
      // Проверяем метод расчёта
      if (_selectedCalculationMethod == null) {
        setState(() {
          _errorMessage = 'Пожалуйста, выберите метод расчёта.';
        });
      } else {
        setState(() {
          _errorMessage = null;
        });
        _nextStep();
      }
    } else if (_currentStep == 2) {
      // Проверяем вес / возраст
      final w = double.tryParse(_weightController.text.trim()) ?? 0.0;
      final a = double.tryParse(_ageController.text.trim()) ?? 0.0;
      if (w <= 0 || a <= 0) {
        setState(() {
          _errorMessage = 'Введите корректные вес и возраст.';
        });
      } else {
        setState(() {
          _errorMessage = null;
        });
        _nextStep();
      }
    } else if (_currentStep == 3) {
      // Завершение шага
      // Можно добавить логику завершения калькуляции или перехода на другой экран
    }
  }

  // Отображение формы добавления вручную
  Widget _buildManualEntryForm() {
    return Form(
      key: _manualFormKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Название'),
            onSaved: (val) => _manualName = val?.trim() ?? '',
            validator: (val) =>
            (val == null || val.isEmpty) ? 'Введите название' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Дозировка (число)'),
            onSaved: (val) => _manualDosage = val?.trim() ?? '',
            validator: (val) =>
            (val == null || val.isEmpty) ? 'Введите дозировку' : null,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<DosageUnit>(
            decoration: const InputDecoration(labelText: 'Единица дозировки'),
            value: _manualDosageUnit,
            items: DosageUnit.values.map((du) {
              return DropdownMenuItem<DosageUnit>(
                value: du,
                child: Text(du.displayName),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _manualDosageUnit = val ?? DosageUnit.mgPerKg;
              });
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<FormType>(
            decoration: const InputDecoration(labelText: 'Форма выпуска'),
            value: _manualFormType,
            items: FormType.values.map((ft) {
              return DropdownMenuItem<FormType>(
                value: ft,
                child: Text(ft.displayName),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _manualFormType = val ?? FormType.tablet;
                if (_manualFormType == FormType.tablet) {
                  _manualAdministrationRoute = AdministrationRoute.oral;
                }
              });
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<AdministrationRoute>(
            decoration: const InputDecoration(labelText: 'Путь введения'),
            value: _manualAdministrationRoute,
            items: AdministrationRoute.values.map((ar) {
              return DropdownMenuItem<AdministrationRoute>(
                value: ar,
                child: Text(ar.displayName),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _manualAdministrationRoute =
                    val ?? AdministrationRoute.oral;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор лекарств'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
          ),
        ],
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onContinue,
        onStepCancel: _previousStep,
        controlsBuilder: (context, details) {
          return Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: const Text('Далее'),
              ),
              const SizedBox(width: 8),
              if (_currentStep > 0)
                OutlinedButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Назад'),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Шаг 1: Выбор препарата'),
            content: _buildStepContent(0),
            isActive: _currentStep >= 0,
            state:
            _currentStep > 0 ? StepState.complete : StepState.editing,
          ),
          Step(
            title: const Text('Шаг 2: Метод расчёта'),
            content: _buildStepContent(1),
            isActive: _currentStep >= 1,
            state:
            _currentStep > 1 ? StepState.complete : StepState.editing,
          ),
          Step(
            title: const Text('Шаг 3: Ввод данных'),
            content: _buildStepContent(2),
            isActive: _currentStep >= 2,
            state:
            _currentStep > 2 ? StepState.complete : StepState.editing,
          ),
          Step(
            title: const Text('Шаг 4: Результат'),
            content: _buildStepContent(3),
            isActive: _currentStep >= 3,
            state: _calculatedDose != null
                ? StepState.complete
                : StepState.editing,
          ),
        ],
      ),
    );
  }
}
