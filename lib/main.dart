// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'models/health_data.dart';
import 'utils/theme_manager.dart';

// Импорт экранов калькулятора
import 'calculator/screens/medication_calculator_screen.dart';
import 'calculator/screens/calculation_history_screen.dart';

// Импорт остальных экранов
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/support_screen.dart';
import 'screens/blood_pressure_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/view_feedback_screen.dart';
import 'screens/profile_screen.dart';

// Импорт экранов для расшифровки анализов
import 'analysis/screens/analysis_main_screen.dart';
import 'analysis/screens/analysis_history_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => HealthData(),
      child: const HillApp(),
    ),
  );
}

class HillApp extends StatefulWidget {
  const HillApp({Key? key}) : super(key: key);

  @override
  State<HillApp> createState() => _HillAppState();
}

class _HillAppState extends State<HillApp> {
  /// Текущее состояние темы: светлая или тёмная
  ThemeMode _themeMode = ThemeMode.light;

  /// Переключатель темы (если понадобится в будущем)
  void _toggleTheme() {
    setState(() {
      _themeMode =
      (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HillApp',
      debugShowCheckedModeBanner: false,

      /// Подключаем кастомные темы из `theme_manager.dart`
      theme: ThemeManager.lightTheme.copyWith(useMaterial3: true),
      darkTheme: ThemeManager.darkTheme.copyWith(useMaterial3: true),
      themeMode: _themeMode,

      /// Поддержка локализаций
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', ''),
        Locale('en', ''),
      ],

      /// Начальный экран (заменён на '/home')
      initialRoute: '/home',

      /// Словарь маршрутов (удалены маршруты логина и регистрации)
      routes: {
        '/home': (context) => const HomeScreen(),
        '/calendar': (context) => const CalendarScreen(),

        // Экран калькулятора лекарств и история расчётов
        '/medication_calculator': (context) =>
        const MedicationCalculatorScreen(),
        '/calculation_history': (context) =>
        const CalculationHistoryScreen(),

        // Дополнительные экраны
        '/support': (context) => const SupportScreen(),
        '/blood_pressure': (context) => const BloodPressureScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/view_feedback': (context) => const ViewFeedbackScreen(),

        // Экраны для расшифровки анализов
        '/analysis_main': (context) => const AnalysisMainScreen(),
        '/analysis_history': (context) => const AnalysisHistoryScreen(),

        // Новый маршрут для ProfileScreen
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
