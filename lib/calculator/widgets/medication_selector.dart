// lib/calculator/widgets/medication_selector.dart

import 'package:flutter/material.dart';
import '../models/medication.dart';

class MedicationSelector extends StatelessWidget {
  final List<Medication> medications;
  final Medication? selectedMedication;
  final ValueChanged<Medication?> onChanged;
  final VoidCallback onManualEntry;

  const MedicationSelector({
    Key? key,
    required this.medications,
    required this.selectedMedication,
    required this.onChanged,
    required this.onManualEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<Medication>(
          decoration: const InputDecoration(
            labelText: 'Выберите препарат',
            border: OutlineInputBorder(),
          ),
          value: selectedMedication,
          items: medications.map((Medication med) {
            return DropdownMenuItem<Medication>(
              value: med,
              child: Text(med.name),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null) {
              return 'Пожалуйста, выберите препарат или добавьте вручную.';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onManualEntry,
          icon: const Icon(Icons.add),
          label: const Text('Добавить вручную'),
        ),
      ],
    );
  }
}
