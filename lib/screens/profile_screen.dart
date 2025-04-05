import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import 'app_info_screen.dart';
// Импортируем сервис уведомлений
import '../services/daily_reminder_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Настройки приложения
  bool notificationsEnabled = true;

  // Переключение уведомлений
  void _toggleNotifications(bool? value) {
    if (value == null) return;
    setState(() {
      notificationsEnabled = value;
    });

    // Если уведомления включены — планируем ежедневные уведомления (на 12:00 и 21:00),
    // если выключены — отменяем их
    if (notificationsEnabled) {
      DailyReminderService().scheduleDailyReminder();
    } else {
      DailyReminderService().cancelReminder();
    }
  }

  // 1. Написать нам (всплывающее окно)
  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Написать нам'),
        content: const Text(
          'Если вы заметили какие-либо ошибки или недочёты в работе приложения, '
              'пожалуйста, сообщите нам об этом по электронной почте:\n'
              'dmitrymozol.dev@gmail.com\n\n'
              'Ваш отзыв поможет нам сделать приложение ещё лучше и удобнее для всех пользователей!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 2. Оценить приложение (всплывающее окно)
  void _showRateAppDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Оценить приложение'),
        content: const Text(
          'Нравится ли вам приложение?\n'
              'Поставьте оценку и помогите нам стать лучше!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Позже'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Здесь можно открыть маркет или форму для оценки
              // Например, Play Store, App Store или собственную логику
            },
            child: const Text('Оценить'),
          ),
        ],
      ),
    );
  }

  // 3. Переход на экран «О приложении»
  void _openAppInfoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AppInfoScreen()),
    );
  }

  // Вспомогательный метод для вывода ошибок (если понадобится)
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------- Раздел "Настройки" ----------
            _buildSectionTitle('Настройки'),
            const SizedBox(height: 8),
            _buildSwitchOption(
              icon: Icons.notifications,
              label: 'Уведомления',
              value: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            const SizedBox(height: 24),

            // ---------- Раздел "Обратная связь" ----------
            _buildSectionTitle('Обратная связь'),
            const SizedBox(height: 8),
            _buildProfileOption(
              icon: Icons.feedback,
              label: 'Написать нам',
              onTap: _showFeedbackDialog,
            ),
            _buildProfileOption(
              icon: Icons.star_outline,
              label: 'Оценить приложение',
              onTap: _showRateAppDialog,
            ),
            const SizedBox(height: 24),

            // ---------- Раздел "О приложении" ----------
            _buildSectionTitle('О приложении'),
            const SizedBox(height: 8),
            _buildProfileOption(
              icon: Icons.info_outline,
              label: 'Информация',
              onTap: _openAppInfoScreen,
            ),
          ],
        ),
      ),
    );
  }

  // Заголовок секции
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.lato(
          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.kMintDark,
          ),
        ),
      ),
    );
  }

  // Виджет с иконкой + текст + стрелочка
  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.kMintDark),
        title: Text(
          label,
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.black87,
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Виджет с переключателем
  Widget _buildSwitchOption({
    required IconData icon,
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.kMintDark),
        title: Text(
          label,
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.black87,
            ),
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
