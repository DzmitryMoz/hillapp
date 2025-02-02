// lib/screens/profile_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Основная информация пользователя
  String userName = "Иван Иванов";

  // Для аватарки
  File? _avatarImage;

  // Настройки приложения
  bool notificationsEnabled = true;
  String selectedLanguage = "Русский";

  // Выбор аватарки
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
      // Здесь можно добавить сохранение аватарки локально или на сервере
    }
  }

  // Смена имени
  Future<void> _changeName() async {
    String? newName =
    await _showInputDialog("Смена имени", "Введите новое имя", userName);
    if (newName != null && newName.trim().isNotEmpty) {
      setState(() {
        userName = newName.trim();
      });
      // Здесь можно добавить обновление имени на сервере, если потребуется
    }
  }

  // Переключение уведомлений
  void _toggleNotifications(bool? value) {
    if (value == null) return;
    setState(() {
      notificationsEnabled = value;
    });
    // Здесь можно сохранить настройки уведомлений
  }

  // Выбор языка
  Future<void> _selectLanguage() async {
    String? language = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text("Выберите язык"),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, "Русский"),
            child: const Text("Русский"),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, "Английский"),
            child: const Text("Английский"),
          ),
          // Добавьте другие языки по необходимости
        ],
      ),
    );

    if (language != null) {
      setState(() {
        selectedLanguage = language;
      });
      // Здесь можно обновить язык приложения
    }
  }

  // Открытие FAQ
  Future<void> _openFAQ() async {
    const faqUrl = 'https://yourapp.com/faq'; // Замените на реальный URL
    if (await canLaunch(faqUrl)) {
      await launch(faqUrl);
    } else {
      _showErrorDialog("Не удалось открыть FAQ");
    }
  }

  // Открытие обратной связи
  Future<void> _openFeedback() async {
    const emailUrl =
        'mailto:support@yourapp.com?subject=Обратная связь'; // Замените при необходимости
    if (await canLaunch(emailUrl)) {
      await launch(emailUrl);
    } else {
      _showErrorDialog("Не удалось открыть почтовый клиент");
    }
  }

  // Вспомогательные методы

  Future<String?> _showInputDialog(
      String title, String hint, String initialValue,
      {bool obscureText = false}) async {
    String? input;
    TextEditingController controller = TextEditingController(text: initialValue);
    await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          obscureText: obscureText,
          decoration: InputDecoration(hintText: hint),
          onChanged: (val) => input = val,
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, input);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    return input;
  }

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
    // Используем текущую тему для текста
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Аватарка и имя
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _avatarImage != null
                        ? FileImage(_avatarImage!)
                        : const AssetImage('assets/images/avatar.png')
                    as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: CircleAvatar(
                      backgroundColor: AppColors.kMintDark,
                      radius: 16,
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: AppColors.kWhite),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: GoogleFonts.lato(
                textStyle: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.kMintDark,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Раздел "Профиль"
            _buildSectionTitle('Профиль'),
            const SizedBox(height: 8),
            _buildProfileOption(
              icon: Icons.person,
              label: 'Изменить имя',
              value: '',
              onTap: _changeName,
            ),
            const SizedBox(height: 24),

            // Раздел "Настройки Приложения"
            _buildSectionTitle('Настройки Приложения'),
            const SizedBox(height: 8),
            _buildSwitchOption(
              icon: Icons.notifications,
              label: 'Уведомления',
              value: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            _buildProfileOption(
              icon: Icons.language,
              label: 'Язык',
              value: selectedLanguage,
              onTap: _selectLanguage,
            ),
            const SizedBox(height: 24),

            // Раздел "Поддержка и обратная связь"
            _buildSectionTitle('Поддержка и обратная связь'),
            const SizedBox(height: 8),
            _buildProfileOption(
              icon: Icons.help_outline,
              label: 'Часто задаваемые вопросы',
              onTap: _openFAQ,
            ),
            _buildProfileOption(
              icon: Icons.feedback,
              label: 'Обратная связь',
              onTap: _openFeedback,
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательный метод для заголовков разделов
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

  // Универсальный виджет для настроек с иконкой и стрелкой
  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String value = "",
    bool isDanger = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isDanger ? Colors.red : AppColors.kMintDark),
        title: Text(
          label,
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDanger ? Colors.red : Colors.black87,
            ),
          ),
        ),
        trailing: value.isNotEmpty
            ? Text(
          value,
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
        )
            : const Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Виджет для переключателей
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
