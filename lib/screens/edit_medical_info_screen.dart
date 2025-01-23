// lib/screens/edit_medical_info_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class EditMedicalInfoScreen extends StatefulWidget {
  final String gender;
  final DateTime birthDate;
  final double height;
  final double weight;
  final List<String> chronicDiseases;
  final List<String> allergies;

  const EditMedicalInfoScreen({
    Key? key,
    required this.gender,
    required this.birthDate,
    required this.height,
    required this.weight,
    required this.chronicDiseases,
    required this.allergies,
  }) : super(key: key);

  @override
  State<EditMedicalInfoScreen> createState() => _EditMedicalInfoScreenState();
}

class _EditMedicalInfoScreenState extends State<EditMedicalInfoScreen> {
  late String _gender;
  late DateTime _birthDate;
  late double _height;
  late double _weight;
  late List<String> _chronicDiseases;
  late List<String> _allergies;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _gender = widget.gender;
    _birthDate = widget.birthDate;
    _height = widget.height;
    _weight = widget.weight;
    _chronicDiseases = List<String>.from(widget.chronicDiseases);
    _allergies = List<String>.from(widget.allergies);
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _addChronicDisease() async {
    String? disease = await _showInputDialog("Добавить хроническое заболевание", "Введите название заболевания");
    if (disease != null && disease.trim().isNotEmpty) {
      setState(() {
        _chronicDiseases.add(disease.trim());
      });
    }
  }

  void _removeChronicDisease(int index) {
    setState(() {
      _chronicDiseases.removeAt(index);
    });
  }

  void _addAllergy() async {
    String? allergy = await _showInputDialog("Добавить аллергию", "Введите название аллергии");
    if (allergy != null && allergy.trim().isNotEmpty) {
      setState(() {
        _allergies.add(allergy.trim());
      });
    }
  }

  void _removeAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
    });
  }

  Future<String?> _showInputDialog(String title, String hint) async {
    String? input;
    TextEditingController controller = TextEditingController();
    await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          decoration: InputDecoration(
            hintText: hint,
          ),
          onChanged: (val) => input = val,
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, input);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    return input;
  }

  void _saveMedicalInfo() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      Navigator.pop(context, {
        'gender': _gender,
        'birthDate': _birthDate,
        'height': _height,
        'weight': _weight,
        'chronicDiseases': _chronicDiseases,
        'allergies': _allergies,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать медицинскую информацию'),
        backgroundColor: AppColors.kMintDark,
      ),
      backgroundColor: AppColors.kBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Пол
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Пол',
                  border: OutlineInputBorder(),
                ),
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'Мужской', child: Text('Мужской')),
                  DropdownMenuItem(value: 'Женский', child: Text('Женский')),
                  DropdownMenuItem(value: 'Другой', child: Text('Другой')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _gender = val);
                },
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Выберите пол';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Дата рождения
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Дата рождения: ${_birthDate.day.toString().padLeft(2, '0')}.${_birthDate.month.toString().padLeft(2, '0')}.${_birthDate.year}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickBirthDate,
                    child: const Text('Выбрать дату'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Рост
              TextFormField(
                initialValue: _height.toString(),
                decoration: const InputDecoration(
                  labelText: 'Рост (см)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Введите рост';
                  if (double.tryParse(val) == null) return 'Введите корректное число';
                  return null;
                },
                onSaved: (val) => _height = double.parse(val!),
              ),
              const SizedBox(height: 16),

              // Вес
              TextFormField(
                initialValue: _weight.toString(),
                decoration: const InputDecoration(
                  labelText: 'Вес (кг)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Введите вес';
                  if (double.tryParse(val) == null) return 'Введите корректное число';
                  return null;
                },
                onSaved: (val) => _weight = double.parse(val!),
              ),
              const SizedBox(height: 16),

              // Хронические заболевания
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Хронические заболевания',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addChronicDisease,
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _chronicDiseases.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_chronicDiseases[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeChronicDisease(index),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Аллергии
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Аллергии',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addAllergy,
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _allergies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_allergies[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeAllergy(index),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Кнопка сохранения
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveMedicalInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kMintDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Сохранить',
                    style: TextStyle(fontSize: 18, color: AppColors.kWhite),
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
