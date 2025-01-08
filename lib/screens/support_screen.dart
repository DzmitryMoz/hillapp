// lib/screens/support_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/support_service.dart';
import '../models/support_ticket.dart';
import '../services/user_profile_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final SupportService _supportService = SupportService();
  final UserProfileService _userProfileService = UserProfileService();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _supportService.init();
  }

  void _submitTicket() async {
    final userProfile = _userProfileService.userProfile;
    if (userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, настройте профиль пользователя')),
      );
      return;
    }

    final ticket = SupportTicket(
      id: const Uuid().v4(),
      userId: 'user123', // Замените на актуальный ID пользователя
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    await _supportService.insertTicket(ticket);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ваш запрос отправлен в поддержку.')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Поддержка'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Тема',
                ),
              ),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Сообщение',
                ),
                maxLines: 5,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submitTicket,
                child: const Text('Отправить'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ));
  }
}
