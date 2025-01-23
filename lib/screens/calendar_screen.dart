// lib/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

// Подключаем модели и сервисы для логики
import '../calculator/models/calendar_medication.dart';
import '../calculator/models/calendar_medication_intake.dart';
import '../calculator/services/calendar_database_service.dart';

// Подключаем utils, где есть getIntakeTypeColor (или доп. методы)
import '../utils/color_utils.dart';

// Пример базовых констант (можно вынести в app_colors.dart)
const Color kMintLight = Color(0xFF00E5D1);
const Color kMintDark  = Color(0xFF00B4AB);
const Color kBackground= Color(0xFFE3FDFD);

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarDatabaseService _calendarDbService = CalendarDatabaseService();

  late final ValueNotifier<List<CalendarMedicationIntake>> _selectedMedications;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  /// Сопоставление medicationId -> CalendarMedication
  Map<String, CalendarMedication> _medicationMap = {};

  @override
  void initState() {
    super.initState();
    _selectedMedications = ValueNotifier([]);
    _loadMedications();
    _updateSelectedMedications(_selectedDay);
  }

  /// Загрузка всех препаратов для календаря и создание карты
  Future<void> _loadMedications() async {
    final meds = await _calendarDbService.getAllCalendarMedications();
    setState(() {
      _medicationMap = { for (var med in meds) med.id: med };
    });
  }

  /// Обновление списка приёмов на выбранную дату
  void _updateSelectedMedications(DateTime day) async {
    final meds = await _calendarDbService.getMedicationsForDay(day);
    _selectedMedications.value = meds;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Обработка нажатия на день календаря
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!_sameDay(selectedDay, _selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _updateSelectedMedications(selectedDay);
    }
  }

  /// Открытие формы «Добавить препарат»
  void _addMedication() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: AddMedicationForm(
              initialDate: _selectedDay,
              onAdd: (
                  medicationName,
                  dosage,
                  dosageUnit,
                  formType,
                  administrationRoute,
                  intakeType,
                  day,
                  time,
                  ) async {
                // Проверяем наличие препарата
                final existingMedication =
                await _calendarDbService.getCalendarMedicationByName(medicationName);

                String medicationId;
                if (existingMedication != null) {
                  medicationId = existingMedication.id;
                } else {
                  // Создаем новый препарат
                  medicationId = const Uuid().v4();
                  final newMedication = CalendarMedication(
                    id: medicationId,
                    name: medicationName,
                    dosage: dosage,
                    dosageUnit: dosageUnit,
                    formType: formType,
                    administrationRoute: administrationRoute,
                  );
                  await _calendarDbService.insertCalendarMedication(newMedication);

                  // Обновляем карту
                  setState(() {
                    _medicationMap[medicationId] = newMedication;
                  });
                }

                // Создаём запись о приёме
                final updatedIntake = CalendarMedicationIntake(
                  id: const Uuid().v4(),
                  medicationId: medicationId,
                  day: day,
                  time: time,
                  intakeType: intakeType,
                );
                await _calendarDbService.insertCalendarMedicationIntake(updatedIntake);

                // Закрытие bottomSheet, обновление UI
                if (mounted) {
                  Navigator.pop(ctx);
                  _updateSelectedMedications(updatedIntake.day);
                  setState(() {
                    _selectedDay = updatedIntake.day;
                    _focusedDay = updatedIntake.day;
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  /// Удаление приёма препарата
  Future<void> _deleteMedicationIntake(String intakeId) async {
    await _calendarDbService.deleteCalendarMedicationIntake(intakeId);
    _updateSelectedMedications(_selectedDay);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Прием препарата удален')),
    );
  }

  @override
  void dispose() {
    _selectedMedications.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Градиентная шапка
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kMintDark, kMintLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: Text(
                'Календарь приёмов',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),

      // фоновый цвет
      backgroundColor: kBackground,

      body: Column(
        children: [
          const SizedBox(height: 12),
          // Календарь в "карточке"
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar<CalendarMedicationIntake>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => _sameDay(day, _selectedDay),
                onDaySelected: _onDaySelected,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                eventLoader: (day) {
                  if (_sameDay(day, _selectedDay)) {
                    return _selectedMedications.value;
                  }
                  return [];
                },
                calendarStyle: const CalendarStyle(
                  // Цвета для сегодняшней и выбранной даты
                  todayDecoration: BoxDecoration(
                    color: kMintLight,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: kMintDark,
                    shape: BoxShape.circle,
                  ),
                  // Отключаем стандартные точечные маркеры
                  markerDecoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: true,
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 1.0,
                        children: events.map((medIntake) {
                          final medication =
                          _medicationMap[medIntake.medicationId];
                          if (medication == null) return const SizedBox();
                          return Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: getIntakeTypeColor(medIntake.intakeType),
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Список препаратов на выбранный день
          Expanded(
            child: ValueListenableBuilder<List<CalendarMedicationIntake>>(
              valueListenable: _selectedMedications,
              builder: (context, medications, _) {
                if (medications.isEmpty) {
                  return const Center(
                    child: Text('Нет приёма препаратов на этот день.'),
                  );
                }
                return ListView.builder(
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final medIntake = medications[index];
                    final medication = _medicationMap[medIntake.medicationId];
                    if (medication == null) {
                      return ListTile(
                        title: const Text('Неизвестный препарат'),
                        subtitle: Text(
                          'Время: ${medIntake.time.format(context)}, '
                              'Приём: ${medIntake.intakeType.displayName}',
                        ),
                      );
                    }
                    final timeStr =
                        '${medIntake.time.hour.toString().padLeft(2, '0')}:'
                        '${medIntake.time.minute.toString().padLeft(2, '0')}';
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          getIntakeTypeColor(medIntake.intakeType),
                          radius: 10,
                        ),
                        title: Text(
                          '${medication.name} (${medication.dosage} ${medication.dosageUnit.displayName})',
                        ),
                        subtitle: Text(
                          'Время: $timeStr\nПриём: ${medIntake.intakeType.displayName}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Диалог подтверждения удаления
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Удалить приём?'),
                                content: const Text(
                                  'Вы уверены, что хотите удалить этот приём?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _deleteMedicationIntake(medIntake.id);
                                    },
                                    child: const Text(
                                      'Удалить',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Кнопка «Добавить»
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedication,
        tooltip: 'Добавить препарат',
        backgroundColor: kMintDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ---------------------
// Форма добавления
// ---------------------
class AddMedicationForm extends StatefulWidget {
  final Function(
      String medicationName,
      String dosage,
      DosageUnit dosageUnit,
      FormType formType,
      AdministrationRoute administrationRoute,
      IntakeType intakeType,
      DateTime day,
      TimeOfDay time,
      ) onAdd;
  final DateTime initialDate;

  const AddMedicationForm({
    Key? key,
    required this.onAdd,
    required this.initialDate,
  }) : super(key: key);

  @override
  State<AddMedicationForm> createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends State<AddMedicationForm> {
  final _formKey = GlobalKey<FormState>();
  String medicationName = '';
  String dosage         = '';
  DosageUnit dosageUnit = DosageUnit.mgPerKg;
  FormType formType     = FormType.tablet;
  AdministrationRoute administrationRoute = AdministrationRoute.oral;
  IntakeType intakeType = IntakeType.morning;

  late DateTime selectedDate;
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      widget.onAdd(
        medicationName,
        dosage,
        dosageUnit,
        formType,
        administrationRoute,
        intakeType,
        selectedDate,
        selectedTime,
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: now.subtract(const Duration(days: 3650)),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Чтобы background был белым поверх BottomSheet
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            // снизу уже учтено MediaQuery в родительском Padding
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Добавить препарат',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Название
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Название препарата',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => medicationName = val?.trim() ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Введите название препарата';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Дозировка
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Дозировка',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => dosage = val?.trim() ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Введите дозировку';
                  }
                  return null;
                },
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Единица дозировки
              DropdownButtonFormField<DosageUnit>(
                decoration: const InputDecoration(
                  labelText: 'Единица дозировки',
                  border: OutlineInputBorder(),
                ),
                value: dosageUnit,
                items: DosageUnit.values.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => dosageUnit = val);
                },
              ),
              const SizedBox(height: 16),

              // Форма выпуска
              DropdownButtonFormField<FormType>(
                decoration: const InputDecoration(
                  labelText: 'Форма выпуска',
                  border: OutlineInputBorder(),
                ),
                value: formType,
                items: FormType.values.map((form) {
                  return DropdownMenuItem(
                    value: form,
                    child: Text(form.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      formType = val;
                      if (formType == FormType.tablet) {
                        administrationRoute = AdministrationRoute.oral;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Путь введения
              DropdownButtonFormField<AdministrationRoute>(
                decoration: const InputDecoration(
                  labelText: 'Путь введения',
                  border: OutlineInputBorder(),
                ),
                value: administrationRoute,
                items: AdministrationRoute.values.map((route) {
                  return DropdownMenuItem(
                    value: route,
                    child: Text(route.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => administrationRoute = val);
                },
              ),
              const SizedBox(height: 16),

              // Вид приёма
              DropdownButtonFormField<IntakeType>(
                decoration: const InputDecoration(
                  labelText: 'Вид приёма',
                  border: OutlineInputBorder(),
                ),
                value: intakeType,
                items: IntakeType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => intakeType = val);
                },
              ),
              const SizedBox(height: 16),

              // Дата приёма
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Дата приёма: '
                          '${selectedDate.day.toString().padLeft(2, '0')}.'
                          '${selectedDate.month.toString().padLeft(2, '0')}.'
                          '${selectedDate.year}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Выбрать дату'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Время приёма
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Время приёма: ${selectedTime.format(context)}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickTime,
                    child: const Text('Выбрать время'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Кнопка «Добавить»
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Добавить',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
