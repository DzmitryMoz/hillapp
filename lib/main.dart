import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/health_data.dart';
import 'utils/theme_manager.dart';

// Экраны
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'calculator/screens/imt_calculator_screen.dart';
import 'calendar/screens/calendar_screen.dart';
import 'screens/blood_pressure_screen.dart';
import 'screens/profile_screen.dart';
import 'analysis/screens/analysis_main_screen.dart';
import 'analysis/screens/analysis_history_screen.dart';

// Сервис уведомлений
import 'services/notification_service.dart';

// Если используете сервис ежедневных напоминаний:
import 'services//daily_reminder_service.dart';

// Экран роста/веса
import 'moms/growth_tracking/growth_tracking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем сервис уведомлений (старый)
  await NotificationService().init();

  // Если используете ежедневные напоминания:
  final dailyReminderService = DailyReminderService();
  await dailyReminderService.init();
  // dailyReminderService.scheduleDailyReminder(); // ← по желанию

  runApp(
    ChangeNotifierProvider(
      create: (_) => HealthData(),
      child: const HillApp(),
    ),
  );
}

class HillApp extends StatelessWidget {
  const HillApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Приложение всегда в одной цветовой схеме (lightTheme)
    return MaterialApp(
      // Фиксируем масштаб текста
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      title: 'Карманный доктор',
      debugShowCheckedModeBanner: false,
      theme: ThemeManager.lightTheme.copyWith(useMaterial3: true),
      // Можно вообще убрать darkTheme и themeMode, если не планируется
      darkTheme: ThemeManager.lightTheme.copyWith(useMaterial3: true),
      themeMode: ThemeMode.light,

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
        '/medication_calculator': (context) => const BmiAdvancedCalculatorScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/analysis_main': (context) => const AnalysisMainScreen(),
        '/analysis_history': (context) => const AnalysisHistoryScreen(),
        '/blood_pressure': (context) => const BloodPressureScreen(),
        '/profile': (context) => const ProfileScreen(),

        // Маршрут для роста/веса
        '/growth_tracking': (context) => const GrowthTrackingScreen(),
      },
    );
  }
}
