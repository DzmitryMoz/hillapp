// lib/calculator/widgets/medication_form.dart

import 'package:flutter/material.dart';
import '../models/dosage_unit.dart';
import '../models/form_type.dart';
import '../models/administration_route.dart';

class MedicationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String name;
  final DosageUnit dosageUnit;
  final FormType formType;
  final AdministrationRoute administrationRoute;
  final String dosage;
  final Function(String, DosageUnit, FormType, AdministrationRoute, String) onChanged;

  const MedicationForm({
    Key? key,
    required this.formKey,
    required this.name,
    required this.dosageUnit,
    required this.formType,
    required this.administrationRoute,
    required this.dosage,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: name,
            decoration: const InputDecoration(
              labelText: 'Название препарата',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => onChanged(val, dosageUnit, formType, administrationRoute, dosage),
            validator: (val) =>
            (val == null || val.isEmpty) ? 'Введите название препарата' : null,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<DosageUnit>(
            decoration: const InputDecoration(
              labelText: 'Дозировка',
              border: OutlineInputBorder(),
            ),
            value: dosageUnit,
            items: DosageUnit.values.map((DosageUnit unit) {
              return DropdownMenuItem<DosageUnit>(
                value: unit,
                child: Text(unit.displayName),
              );
            }).toList(),
            onChanged: (DosageUnit? newUnit) {
              if (newUnit != null) {
                onChanged(name, newUnit, formType, administrationRoute, dosage);
              }
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<FormType>(
            decoration: const InputDecoration(
              labelText: 'Форма выпуска',
              border: OutlineInputBorder(),
            ),
            value: formType,
            items: FormType.values.map((FormType form) {
              return DropdownMenuItem<FormType>(
                value: form,
                child: Text(form.displayName),
              );
            }).toList(),
            onChanged: (FormType? newForm) {
              if (newForm != null) {
                // Автоматически устанавливаем путь введения, если форма — таблетки
                AdministrationRoute newRoute = administrationRoute;
                if (newForm == FormType.tablet) {
                  newRoute = AdministrationRoute.oral;
                }
                onChanged(name, dosageUnit, newForm, newRoute, dosage);
              }
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<AdministrationRoute>(
            decoration: const InputDecoration(
              labelText: 'Путь введения',
              border: OutlineInputBorder(),
            ),
            value: administrationRoute,
            items: AdministrationRoute.values.map((AdministrationRoute route) {
              return DropdownMenuItem<AdministrationRoute>(
                value: route,
                child: Text(route.displayName),
              );
            }).toList(),
            onChanged: (AdministrationRoute? newRoute) {
              if (newRoute != null) {
                onChanged(name, dosageUnit, formType, newRoute, dosage);
              }
            },
            validator: (val) {
              if (val == null) {
                return 'Пожалуйста, выберите путь введения.';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: dosage,
            decoration: const InputDecoration(
              labelText: 'Дозировка препарата',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) => onChanged(name, dosageUnit, formType, administrationRoute, val),
            validator: (val) =>
            (val == null || val.isEmpty) ? 'Введите дозировку препарата' : null,
          ),
        ],
      ),
    );
  }
}
