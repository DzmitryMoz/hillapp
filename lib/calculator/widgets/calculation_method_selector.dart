// lib/calculator/widgets/calculation_method_selector.dart

import 'package:flutter/material.dart';
import '../models/calculation_method.dart'; // Корректный путь

class CalculationMethodSelector extends StatefulWidget {
  final ValueChanged<CalculationMethod> onMethodSelected;

  const CalculationMethodSelector({
    Key? key,
    required this.onMethodSelected,
  }) : super(key: key);

  @override
  _CalculationMethodSelectorState createState() =>
      _CalculationMethodSelectorState();
}

class _CalculationMethodSelectorState
    extends State<CalculationMethodSelector> {
  CalculationMethod? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CalculationMethod>(
      decoration: const InputDecoration(
        labelText: 'Выберите метод расчёта',
        border: OutlineInputBorder(),
      ),
      value: _selectedMethod,
      items: CalculationMethod.values.map((CalculationMethod method) {
        return DropdownMenuItem<CalculationMethod>(
          value: method,
          child: Text(method.displayName),
        );
      }).toList(),
      onChanged: (CalculationMethod? newValue) {
        setState(() {
          _selectedMethod = newValue;
        });
        if (newValue != null) {
          widget.onMethodSelected(newValue);
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Пожалуйста, выберите метод расчёта';
        }
        return null;
      },
    );
  }
}
