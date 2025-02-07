// lib/calendar/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

// Импортируем нужные enum и классы из моделей
import '../models/calendar_medication.dart'
    show CalendarMedication,
    DosageUnit,
    DosageUnitExtension,
    FormType,
    FormTypeExtension,
    AdministrationRoute,
    AdministrationRouteExtension; // <-- ВАЖНО, чтобы были enum + extension
import '../models/calendar_medication_intake.dart'
    show CalendarMedicationIntake, IntakeType, IntakeTypeExtension;
import '../service/calendar_database_service.dart';
import '../../utils/color_utils.dart';

const Color kMintLight = Color(0xFF00E5D1);
const Color kMintDark = Color(0xFF00B4AB);
const Color kBackground = Color(0xFFE3FDFD);

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

  /// medicationId -> CalendarMedication
  Map<String, CalendarMedication> _medicationMap = {};

  @override
  void initState() {
    super.initState();
    _selectedMedications = ValueNotifier([]);
    _loadMedications();
    _updateSelectedMedications(_selectedDay);
  }

  Future<void> _loadMedications() async {
    final meds = await _calendarDbService.getAllCalendarMedications();
    setState(() {
      _medicationMap = {for (var med in meds) med.id: med};
    });
  }

  void _updateSelectedMedications(DateTime day) async {
    final meds = await _calendarDbService.getMedicationsForDay(day);
    _selectedMedications.value = meds;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!_sameDay(selectedDay, _selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _updateSelectedMedications(selectedDay);
    }
  }

  /// Открываем форму для добавления препарата
  void _addMedication() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
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
                final existingMedication =
                await _calendarDbService.getCalendarMedicationByName(
                  medicationName,
                );

                String medicationId;
                if (existingMedication != null) {
                  medicationId = existingMedication.id;
                } else {
                  medicationId = const Uuid().v4();
                  final newMedication = CalendarMedication(
                    id: medicationId,
                    name: medicationName,
                    dosage: dosage,
                    dosageUnit: dosageUnit,
                    formType: formType,
                    administrationRoute: administrationRoute,
                  );
                  await _calendarDbService.insertCalendarMedication(
                    newMedication,
                  );
                  setState(() {
                    _medicationMap[medicationId] = newMedication;
                  });
                }

                final newIntake = CalendarMedicationIntake(
                  id: const Uuid().v4(),
                  medicationId: medicationId,
                  day: day,
                  time: time,
                  intakeType: intakeType,
                );
                await _calendarDbService.insertCalendarMedicationIntake(
                  newIntake,
                );

                if (mounted) {
                  Navigator.pop(ctx);
                  _updateSelectedMedications(newIntake.day);
                  setState(() {
                    _selectedDay = newIntake.day;
                    _focusedDay = newIntake.day;
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  /// Открываем форму для редактирования
  void _editMedicationIntake(CalendarMedicationIntake medIntake) {
    final medication = _medicationMap[medIntake.medicationId];
    if (medication == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: EditMedicationForm(
              initialMedication: medication,
              initialIntake: medIntake,
              onEdit: (
                  updatedMedicationName,
                  updatedDosage,
                  updatedDosageUnit,
                  updatedFormType,
                  updatedAdministrationRoute,
                  updatedIntakeType,
                  updatedDay,
                  updatedTime,
                  ) async {
                final updatedMedication = medication.copyWith(
                  name: updatedMedicationName,
                  dosage: updatedDosage,
                  dosageUnit: updatedDosageUnit,
                  formType: updatedFormType,
                  administrationRoute: updatedAdministrationRoute,
                );
                await _calendarDbService.updateCalendarMedication(
                  updatedMedication,
                );

                final updatedIntake = medIntake.copyWith(
                  day: updatedDay,
                  time: updatedTime,
                  intakeType: updatedIntakeType,
                );
                await _calendarDbService.updateCalendarMedicationIntake(
                  updatedIntake,
                );

                Navigator.pop(ctx);
                _loadMedications();
                _updateSelectedMedications(updatedDay);
                setState(() {
                  _selectedDay = updatedDay;
                  _focusedDay = updatedDay;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteMedicationIntake(String intakeId) async {
    await _calendarDbService.deleteCalendarMedicationIntake(intakeId);
    _updateSelectedMedications(_selectedDay);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Приём препарата удалён')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Кнопка «Назад» в AppBar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Возврат на предыдущее меню/экран
            Navigator.pop(context);
          },
        ),
        title: const Text('Календарь приёмов'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kMintDark, kMintLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: kBackground,
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Календарь
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
              eventLoader: (day) =>
              _sameDay(day, _selectedDay) ? _selectedMedications.value : [],
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: kMintLight,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: kMintDark,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: true,
                formatButtonDecoration: BoxDecoration(
                  color: kMintDark,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                formatButtonTextStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Список приёмов
          Expanded(
            child: ValueListenableBuilder<List<CalendarMedicationIntake>>(
              valueListenable: _selectedMedications,
              builder: (context, meds, _) {
                if (meds.isEmpty) {
                  return const Center(
                    child: Text('Нет приёма препаратов на этот день.'),
                  );
                }
                return ListView.builder(
                  itemCount: meds.length,
                  itemBuilder: (context, index) {
                    final medIntake = meds[index];
                    final medication = _medicationMap[medIntake.medicationId];
                    final hh = medIntake.time.hour.toString().padLeft(2, '0');
                    final mm = medIntake.time.minute.toString().padLeft(2, '0');
                    final timeStr = '$hh:$mm';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _editMedicationIntake(medIntake),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            radius: 10,
                          ),
                          title: medication == null
                              ? const Text('Неизвестный препарат')
                              : Text(
                            '${medication.name} '
                                '(${medication.dosage} '
                                '${medication.dosageUnit.displayName})',
                          ),
                          subtitle: Text(
                            'Время: $timeStr\n'
                                'Приём: ${medIntake.intakeType.displayName}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
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
        backgroundColor: kMintDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

/// ---------------------
/// Форма добавления препарата
/// ---------------------
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
  String dosage = '';

  /// Значения по умолчанию
  FormType formType = FormType.tabletka;
  DosageUnit dosageUnit = DosageUnit.mg;
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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
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
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Добавить препарат',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Название препарата
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

              // Форма выпуска
              DropdownButtonFormField<FormType>(
                decoration: const InputDecoration(
                  labelText: 'Форма выпуска',
                  border: OutlineInputBorder(),
                ),
                value: formType,
                items: FormType.values.map((f) {
                  return DropdownMenuItem(
                    value: f,
                    child: Text(f.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => formType = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Единица дозировки
              DropdownButtonFormField<DosageUnit>(
                decoration: const InputDecoration(
                  labelText: 'Единица дозировки',
                  border: OutlineInputBorder(),
                ),
                value: dosageUnit,
                items: DosageUnit.values.map((u) {
                  return DropdownMenuItem(
                    value: u,
                    child: Text(u.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => dosageUnit = val);
                },
              ),
              const SizedBox(height: 16),

              // Количество (дозировка)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Количество (дозировка)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => dosage = val?.trim() ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Введите дозировку';
                  }
                  return null;
                },
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Путь введения (на русском)
              DropdownButtonFormField<AdministrationRoute>(
                decoration: const InputDecoration(
                  labelText: 'Путь введения',
                  border: OutlineInputBorder(),
                ),
                value: administrationRoute,
                items: AdministrationRoute.values.map((r) {
                  // ВАЖНО: Здесь на экране будет то, что вернётся из displayName
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => administrationRoute = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Вид приёма (утро, вечер, ...)
              DropdownButtonFormField<IntakeType>(
                decoration: const InputDecoration(
                  labelText: 'Вид приёма',
                  border: OutlineInputBorder(),
                ),
                value: intakeType,
                items: IntakeType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => intakeType = val);
                  }
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

/// ---------------------
/// Форма редактирования препарата
/// ---------------------
class EditMedicationForm extends StatefulWidget {
  final CalendarMedication initialMedication;
  final CalendarMedicationIntake initialIntake;
  final Function(
      String medicationName,
      String dosage,
      DosageUnit dosageUnit,
      FormType formType,
      AdministrationRoute administrationRoute,
      IntakeType intakeType,
      DateTime day,
      TimeOfDay time,
      ) onEdit;

  const EditMedicationForm({
    Key? key,
    required this.initialMedication,
    required this.initialIntake,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<EditMedicationForm> createState() => _EditMedicationFormState();
}

class _EditMedicationFormState extends State<EditMedicationForm> {
  final _formKey = GlobalKey<FormState>();

  late String medicationName;
  late String dosage;
  late FormType formType;
  late DosageUnit dosageUnit;
  late AdministrationRoute administrationRoute;
  late IntakeType intakeType;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    medicationName = widget.initialMedication.name;
    dosage = widget.initialMedication.dosage;
    dosageUnit = widget.initialMedication.dosageUnit;
    formType = widget.initialMedication.formType;
    administrationRoute = widget.initialMedication.administrationRoute;
    intakeType = widget.initialIntake.intakeType;
    selectedDate = widget.initialIntake.day;
    selectedTime = widget.initialIntake.time;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onEdit(
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
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Редактировать препарат',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Название препарата
              TextFormField(
                initialValue: medicationName,
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

              // Форма выпуска
              DropdownButtonFormField<FormType>(
                decoration: const InputDecoration(
                  labelText: 'Форма выпуска',
                  border: OutlineInputBorder(),
                ),
                value: formType,
                items: FormType.values.map((f) {
                  return DropdownMenuItem(
                    value: f,
                    child: Text(f.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => formType = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Единица дозировки
              DropdownButtonFormField<DosageUnit>(
                decoration: const InputDecoration(
                  labelText: 'Единица дозировки',
                  border: OutlineInputBorder(),
                ),
                value: dosageUnit,
                items: DosageUnit.values.map((u) {
                  return DropdownMenuItem(
                    value: u,
                    child: Text(u.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => dosageUnit = val);
                },
              ),
              const SizedBox(height: 16),

              // Количество (дозировка)
              TextFormField(
                initialValue: dosage,
                decoration: const InputDecoration(
                  labelText: 'Количество (дозировка)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => dosage = val?.trim() ?? '',
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Введите дозировку';
                  }
                  return null;
                },
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Путь введения (на русском)
              DropdownButtonFormField<AdministrationRoute>(
                decoration: const InputDecoration(
                  labelText: 'Путь введения',
                  border: OutlineInputBorder(),
                ),
                value: administrationRoute,
                items: AdministrationRoute.values.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    // ВАЖНО: используем r.displayName,
                    // чтобы показывать русскоязычный вариант
                    child: Text(r.displayName),
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
                items: IntakeType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.displayName),
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

              // Кнопка «Сохранить»
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text(
                    'Сохранить',
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

// Заглушки для update-методов (если нужно)
extension CalendarDatabaseServiceExtensions on CalendarDatabaseService {
  Future<void> updateCalendarMedicationIntake(CalendarMedicationIntake intake) async {
    // TODO: Реализуйте update в базе
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> updateCalendarMedication(CalendarMedication medication) async {
    // TODO: Реализуйте update в базе
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
