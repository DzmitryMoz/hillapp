// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hillapp/calculator/calculator_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/support_screen.dart';
import 'screens/blood_pressure_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/view_feedback_screen.dart';
import 'screens/analysis_list_screen.dart';
import 'screens/analysis_decryption_screen.dart';
import 'screens/analysis_history_screen.dart';

class HillApp extends StatefulWidget {
  const HillApp({Key? key}) : super(key: key);

  @override
  State<HillApp> createState() => _HillAppState();
}

class _HillAppState extends State<HillApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HillApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(onToggleTheme: _toggleTheme),
        '/register': (context) => RegisterScreen(onToggleTheme: _toggleTheme),
        '/home': (context) => HomeScreen(onToggleTheme: _toggleTheme),
        '/calendar': (context) => const CalendarScreen(),
        '/calculator': (context) => const CalculatorScreen(),
        '/support': (context) => const SupportScreen(),
        '/blood_pressure': (context) => const BloodPressureScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/view_feedback': (context) => const ViewFeedbackScreen(),
        '/analysis_list': (context) => const AnalysisListScreen(),
        '/analysis_decryption': (context) => const AnalysisDecryptionScreen(),
        '/analysis_history': (context) => const AnalysisHistoryScreen(),
      },
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HillApp());
}
