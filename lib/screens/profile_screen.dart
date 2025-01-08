// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const ProfileScreen({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Имя пользователя';
  String userEmail = 'user@example.com';
  bool notificationsEnabled = true;

  final TextEditingController _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = userName;
  }

  void _logout() {
    // Реализуйте логику выхода из аккаунта
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _saveProfile() {
    setState(() {
      userName = _nameCtrl.text.trim().isEmpty ? userName : _nameCtrl.text.trim();
    });
    Navigator.pop(context);
  }

  void _openEditProfile() {
    _nameCtrl.text = userName;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Имя пользователя'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleNotifications(bool value) {
    setState(() {
      notificationsEnabled = value;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(userName, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(userEmail),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Уведомления'),
              value: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            SwitchListTile(
              title: const Text('Тёмная тема'),
              value: isDarkMode,
              onChanged: (val) {
                widget.onToggleTheme();
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _openEditProfile,
              child: const Text('Редактировать профиль'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Выйти из аккаунта'),
            ),
          ],
        ),
      ),
    );
  }
}
