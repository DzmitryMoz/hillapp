// lib/analysis/screens/analysis_patient_form.dart

import 'package:flutter/material.dart';
import '../analysis_service.dart';
import 'analysis_input_screen.dart';
import '../analysis_colors.dart';

class AnalysisPatientForm extends StatefulWidget {
  final String researchId;
  final AnalysisService analysisService;

  const AnalysisPatientForm({
    Key? key,
    required this.researchId,
    required this.analysisService,
  }) : super(key: key);

  @override
  State<AnalysisPatientForm> createState() => _AnalysisPatientFormState();
}

class _AnalysisPatientFormState extends State<AnalysisPatientForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _sex; // Изначально не выбрано, значение null

  void _goNext() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameCtrl.text.trim();
      final age = int.parse(_ageCtrl.text.trim());
      // Здесь _sex точно не null, так как форма валидируется
      final sex = _sex!;

      // Переходим на экран ввода показателей
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisInputScreen(
            researchId: widget.researchId,
            analysisService: widget.analysisService,
            patientName: name,
            patientAge: age,
            patientSex: sex,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Данные пациента'),
        backgroundColor: kMintDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Укажите данные пациента',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Имя',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Введите имя';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Возраст (лет)',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Введите возраст';
                    }
                    final num = int.tryParse(val);
                    if (num == null) return 'Некорректное число';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Оборачиваем выбор пола в FormField для валидации
                FormField<String>(
                  validator: (value) {
                    if (_sex == null) {
                      return 'Выберите пол';
                    }
                    return null;
                  },
                  builder: (FormFieldState<String> state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Пол:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 16),
                            Radio<String>(
                              value: 'male',
                              groupValue: _sex,
                              onChanged: (val) {
                                setState(() {
                                  _sex = val;
                                  state.didChange(val);
                                });
                              },
                            ),
                            const Text('Муж.'),
                            const SizedBox(width: 16),
                            Radio<String>(
                              value: 'female',
                              groupValue: _sex,
                              onChanged: (val) {
                                setState(() {
                                  _sex = val;
                                  state.didChange(val);
                                });
                              },
                            ),
                            const Text('Жен.'),
                          ],
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              state.errorText ?? '',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _goNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMintDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Далее'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
