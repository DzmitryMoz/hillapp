// lib/screens/add_pill_dialog.dart

import 'package:flutter/material.dart';

class AddPillDialog extends StatefulWidget {
  const AddPillDialog({Key? key}) : super(key: key);

  @override
  State<AddPillDialog> createState() => _AddPillDialogState();
}

class _AddPillDialogState extends State<AddPillDialog> {
  final _formKey = GlobalKey<FormState>();
  String _pillName = '';
  String _pillTime = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить таблетку'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Название таблетки'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите название таблетки';
                }
                return null;
              },
              onSaved: (value) {
                _pillName = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Время приёма (08:00)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите время приёма';
                }
                if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                  return 'Введите время в формате ЧЧ:ММ';
                }
                return null;
              },
              onSaved: (value) {
                _pillTime = value!;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              final pillData = <String, String>{
                'name': _pillName,
                'time': _pillTime,
              };
              Navigator.pop(context, pillData);
            }
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}
