// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_colors.dart';

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
  }

  // Открытие обратной связи
  Future<void> _openFeedback() async {
    const emailUrl = 'mailto:support@yourapp.com?subject=Обратная связь';
    if (await canLaunch(emailUrl)) {
      await launch(emailUrl);
    } else {
      _showErrorDialog("Не удалось открыть почтовый клиент");
    }
  }

  // Информация о приложении (пример)
  Future<void> _openAppInfo() async {
    // Можете заменить на ваш URL или экран «О приложении»
    const infoUrl = 'https://yourapp.com/about';
    if (await canLaunch(infoUrl)) {
      await launch(infoUrl);
    } else {
      _showErrorDialog("Не удалось открыть страницу информации");
    }
  }

  // Пример пункта: «Оценить приложение»
  Future<void> _openRateApp() async {
    const rateUrl = 'https://yourapp.com/rate';
    if (await canLaunch(rateUrl)) {
      await launch(rateUrl);
    } else {
      _showErrorDialog("Не удалось открыть страницу оценок");
    }
  }

  // Вспомогательный метод для вывода ошибок
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
              onTap: _openFeedback,
            ),
            _buildProfileOption(
              icon: Icons.star_outline,
              label: 'Оценить приложение', // опционально
              onTap: _openRateApp,
            ),

            const SizedBox(height: 24),

            // ---------- Раздел "О приложении" ----------
            _buildSectionTitle('О приложении'),
            const SizedBox(height: 8),
            _buildProfileOption(
              icon: Icons.info_outline,
              label: 'Информация',
              onTap: _openAppInfo,
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
