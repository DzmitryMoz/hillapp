// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/health_data.dart';
import 'utils/theme_manager.dart';

// Импорт других нужных экранов
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'calculator/screens/medication_calculator_screen.dart';
import 'calculator/screens/calculation_history_screen.dart';
import 'calendar/screens/calendar_screen.dart';
import 'screens/blood_pressure_screen.dart';
import 'screens/profile_screen.dart';
import 'analysis/screens/analysis_main_screen.dart';
import 'analysis/screens/analysis_history_screen.dart';

// Импорт сервиса уведомлений (обратите внимание на относительный путь)
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем уведомления
  await NotificationService().init();

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
  ThemeMode _themeMode = ThemeMode.light;

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
      theme: ThemeManager.lightTheme.copyWith(useMaterial3: true),
      darkTheme: ThemeManager.darkTheme.copyWith(useMaterial3: true),
      themeMode: _themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', ''),
        Locale('en', ''),
      ],
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/medication_calculator': (context) =>
        const MedicationCalculatorScreen(),
        '/calculation_history': (context) =>
        const CalculationHistoryScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/analysis_main': (context) => const AnalysisMainScreen(),
        '/analysis_history': (context) => const AnalysisHistoryScreen(),
        '/blood_pressure': (context) => const BloodPressureScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
