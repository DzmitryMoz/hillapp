// lib/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/medication.dart';
import '../models/medication_data.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Medication>> _selectedMedications;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedMedications = ValueNotifier(_getMedications(_selectedDay));
  }

  @override
  void dispose() {
    _selectedMedications.dispose();
    super.dispose();
  }

  List<Medication> _getMedications(DateTime day) {
    return MedicationData().getMedications(day);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!_sameDay(selectedDay, _selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedMedications.value = _getMedications(selectedDay);
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _addMedication() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16),
        child: AddMedicationForm(
          onAdd: (medication) {
            MedicationData().addMedication(_selectedDay, medication);
            _selectedMedications.value = _getMedications(_selectedDay);
            Navigator.pop(ctx);
            setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Полноценный календарь'),
      ),
      body: Column(
        children: [
          TableCalendar<Medication>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => _sameDay(day, _selectedDay),
            onDaySelected: _onDaySelected,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            eventLoader: (day) {
              return MedicationData().getMedications(day);
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder<List<Medication>>(
              valueListenable: _selectedMedications,
              builder: (context, medications, _) {
                if (medications.isEmpty) {
                  return const Center(
                      child: Text('Нет приёма препаратов на этот день.'));
                }
                return ListView.builder(
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final med = medications[index];
                    return Card(
                      child: ListTile(
                        title: Text('${med.name} (${med.dosage})'),
                        subtitle: Text(
                            'Время: ${med.time.format(context)}, Приём: ${med.intakeType.displayName}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedication,
        child: const Icon(Icons.add),
        tooltip: 'Добавить препарат',
      ),
    );
  }
}

class AddMedicationForm extends StatefulWidget {
  final Function(Medication) onAdd;
  const AddMedicationForm({Key? key, required this.onAdd}) : super(key: key);

  @override
  State<AddMedicationForm> createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends State<AddMedicationForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String dosage = '';
  IntakeType intakeType = IntakeType.morning;
  TimeOfDay time = const TimeOfDay(hour: 8, minute: 0);

  final List<IntakeType> intakeTypes = [
    IntakeType.morning,
    IntakeType.evening,
    IntakeType.single,
    IntakeType.course
  ];

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final med = Medication(
        name: name,
        dosage: dosage,
        intakeType: intakeType,
        time: time,
      );
      widget.onAdd(med);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: time,
    );
    if (picked != null && picked != time) {
      setState(() {
        time = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding:
          const EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Добавить препарат',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                decoration:
                const InputDecoration(labelText: 'Название препарата'),
                onSaved: (val) => name = val!.trim(),
                validator: (val) =>
                (val == null || val.isEmpty) ? 'Введите название' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Дозировка'),
                onSaved: (val) => dosage = val!.trim(),
                validator: (val) =>
                (val == null || val.isEmpty) ? 'Введите дозировку' : null,
              ),
              DropdownButtonFormField<IntakeType>(
                decoration: const InputDecoration(labelText: 'Вид приёма'),
                value: intakeType,
                items: intakeTypes.map((type) {
                  return DropdownMenuItem(
                      value: type, child: Text(type.displayName));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    intakeType = val!;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('Время приёма: ${time.format(context)}'),
                  ),
                  TextButton(
                    onPressed: _pickTime,
                    child: const Text('Выбрать время'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Добавить'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
