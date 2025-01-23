// lib/screens/profile_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_colors.dart'; // Файл с константами цветов
import 'edit_medical_info_screen.dart'; // Импортируем EditMedicalInfoScreen

class ProfileScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const ProfileScreen({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Пример данных пользователя
  String userName = "Иван Иванов";
  String email = "ivan.ivanov@example.com";
  String gender = "Мужской";
  DateTime birthDate = DateTime(1990, 5, 20);
  double height = 175.0; // в сантиметрах
  double weight = 70.0;  // в килограммах

  // Медицинские данные
  List<String> chronicDiseases = ["Гипертония"];
  List<String> allergies = ["Пенициллин"];

  // Для аватарки
  File? _avatarImage;

  // Для уведомлений и языка
  bool notificationsEnabled = true;
  String selectedLanguage = "Русский";

  // Переключение темы
  void _toggleTheme() {
    widget.onToggleTheme();
  }

  // Выбор аватарки
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
      // Здесь вы можете загрузить аватарку на сервер или сохранить локально
    }
  }

  // Смена имени
  Future<void> _changeName() async {
    String? newName = await _showInputDialog("Смена имени", "Введите новое имя", userName);
    if (newName != null && newName.trim().isNotEmpty) {
      setState(() {
        userName = newName.trim();
      });
      // Здесь вы можете обновить имя на сервере
    }
  }

  // Смена Email
  Future<void> _changeEmail() async {
    String? newEmail = await _showInputDialog("Смена Email", "Введите новый Email", email);
    if (newEmail != null && newEmail.trim().isNotEmpty) {
      // Валидация Email
      if (!_isValidEmail(newEmail.trim())) {
        _showErrorDialog("Некорректный Email");
        return;
      }
      setState(() {
        email = newEmail.trim();
      });
      // Здесь вы можете обновить Email на сервере
    }
  }

  // Смена пароля
  Future<void> _changePassword() async {
    String? currentPassword = await _showInputDialog("Смена пароля", "Введите текущий пароль", "", obscureText: true);
    if (currentPassword == null || currentPassword.isEmpty) return;

    String? newPassword = await _showInputDialog("Смена пароля", "Введите новый пароль", "", obscureText: true);
    if (newPassword == null || newPassword.isEmpty) return;

    String? confirmPassword = await _showInputDialog("Смена пароля", "Подтвердите новый пароль", "", obscureText: true);
    if (confirmPassword == null || confirmPassword.isEmpty) return;

    if (newPassword != confirmPassword) {
      _showErrorDialog("Пароли не совпадают");
      return;
    }

    // Здесь вы можете проверить текущий пароль и обновить его на сервере
    _showSuccessDialog("Пароль успешно изменён");
  }

  // Удаление аккаунта
  Future<void> _deleteAccount() async {
    bool? confirm = await _showConfirmationDialog("Удаление аккаунта", "Вы уверены, что хотите удалить аккаунт? Все ваши данные будут удалены.");
    if (confirm != null && confirm) {
      // Здесь вы можете реализовать логику удаления аккаунта на сервере
      _showSuccessDialog("Аккаунт успешно удалён");
      // Например, выйти из приложения или перенаправить на экран регистрации
    }
  }

  // Настройка уведомлений
  void _toggleNotifications(bool? value) {
    if (value == null) return;
    setState(() {
      notificationsEnabled = value;
    });
    // Здесь вы можете обновить настройки уведомлений на сервере или локально
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
      // Здесь вы можете обновить язык приложения
    }
  }

  // Кнопка для изменения медицинской информации
  Future<void> _editMedicalInfo() async {
    final updatedData = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditMedicalInfoScreen(
          gender: gender,
          birthDate: birthDate,
          height: height,
          weight: weight,
          chronicDiseases: chronicDiseases,
          allergies: allergies,
        ),
      ),
    );

    if (updatedData != null) {
      setState(() {
        gender = updatedData['gender'] as String;
        birthDate = updatedData['birthDate'] as DateTime;
        height = updatedData['height'] as double;
        weight = updatedData['weight'] as double;
        chronicDiseases = List<String>.from(updatedData['chronicDiseases'] as List<dynamic>);
        allergies = List<String>.from(updatedData['allergies'] as List<dynamic>);
      });
      _showSuccessDialog("Медицинская информация успешно обновлена.");
    }
  }

  // FAQ
  Future<void> _openFAQ() async {
    const faqUrl = 'https://yourapp.com/faq'; // Замените на реальный URL
    if (await canLaunch(faqUrl)) {
      await launch(faqUrl);
    } else {
      _showErrorDialog("Не удалось открыть FAQ");
    }
  }

  // Обратная связь
  Future<void> _openFeedback() async {
    // Здесь вы можете реализовать форму обратной связи или открыть email
    const emailUrl = 'mailto:support@yourapp.com?subject=Обратная связь';
    if (await canLaunch(emailUrl)) {
      await launch(emailUrl);
    } else {
      _showErrorDialog("Не удалось открыть почтовый клиент");
    }
  }

  // Выход из аккаунта
  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Добавьте логику выхода из аккаунта, например, очистку данных и перенаправление на экран входа
            },
            child: const Text(
              'Выйти',
              style: TextStyle(color: AppColors.kRedAccent),
            ),
          ),
        ],
      ),
    );
  }

  // Вспомогательные методы

  Future<String?> _showInputDialog(String title, String hint, String initialValue, {bool obscureText = false}) async {
    String? input;
    TextEditingController controller = TextEditingController(text: initialValue);
    await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
          ),
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

  Future<bool?> _showConfirmationDialog(String title, String content) async {
    bool? confirm = false;
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Подтвердить',
              style: TextStyle(color: AppColors.kRedAccent),
            ),
          ),
        ],
      ),
    ).then((value) => confirm = value);
    return confirm;
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Успех'),
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

  bool _isValidEmail(String email) {
    // Простая валидация Email
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    // Обновлённые свойства TextTheme
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Аватарка и основная информация
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _avatarImage != null
                        ? FileImage(_avatarImage!)
                        : const AssetImage('assets/images/avatar.png') as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: CircleAvatar(
                      backgroundColor: AppColors.kMintDark,
                      radius: 16,
                      child: const Icon(Icons.camera_alt, size: 18, color: AppColors.kWhite),
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
            const SizedBox(height: 8),
            Text(
              email,
              style: GoogleFonts.lato(
                textStyle: textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Персональная Информация
            _buildSectionTitle('Персональная Информация'),
            const SizedBox(height: 8),
            _buildProfileOption(
              icon: Icons.person,
              label: 'Имя',
              value: userName,
              onTap: _changeName,
            ),
            _buildProfileOption(
              icon: Icons.email,
              label: 'Email',
              value: email,
              onTap: _changeEmail,
            ),
            const SizedBox(height: 24),

            // Медицинская Информация
            _buildSectionTitle('Медицинская Информация'),
            const SizedBox(height: 8),
            _buildInfoRow('Пол', gender),
            _buildInfoRow('Дата рождения', "${birthDate.day.toString().padLeft(2, '0')}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.year}"),
            _buildInfoRow('Рост', "$height см"),
            _buildInfoRow('Вес', "$weight кг"),
            _buildInfoRow('Хронические заболевания', chronicDiseases.isNotEmpty ? chronicDiseases.join(', ') : 'Нет'),
            _buildInfoRow('Аллергии', allergies.isNotEmpty ? allergies.join(', ') : 'Нет'),
            const SizedBox(height: 8),
            _buildEditMedicalInfoButton(),
            const SizedBox(height: 24),

            // Настройки Приложения
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

            // Безопасность
            _buildSectionTitle('Безопасность'),
            const SizedBox(height: 8),
            _buildProfileOption(
              icon: Icons.lock,
              label: 'Изменить пароль',
              value: '',
              onTap: _changePassword,
            ),
            _buildProfileOption(
              icon: Icons.email,
              label: 'Изменить Email',
              value: '',
              onTap: _changeEmail,
            ),
            _buildProfileOption(
              icon: Icons.delete_forever,
              label: 'Удалить аккаунт',
              value: '',
              onTap: _deleteAccount,
              isDanger: true,
            ),
            const SizedBox(height: 24),

            // Поддержка и Обратная Связь
            _buildSectionTitle('Поддержка и Обратная Связь'),
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
            const SizedBox(height: 24),

            // Выход из аккаунта
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  // Вспомогательные методы для создания элементов интерфейса

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
        leading: Icon(icon, color: isDanger ? Colors.red : AppColors.kMintDark),
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
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$label:",
              style: GoogleFonts.lato(
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: GoogleFonts.lato(
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildEditMedicalInfoButton() {
    return ElevatedButton.icon(
      onPressed: _editMedicalInfo,
      icon: const Icon(Icons.edit, color: AppColors.kWhite),
      label: const Text(
        'Изменить информацию',
        style: TextStyle(color: AppColors.kWhite),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.kMintDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, color: AppColors.kWhite),
        label: const Text(
          'Выйти',
          style: TextStyle(color: AppColors.kWhite),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kRedAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
