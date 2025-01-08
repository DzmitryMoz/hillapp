// lib/screens/feedback_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/feedback_service.dart';
import '../models/feedback.dart';
import '../services/user_profile_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  final UserProfileService _userProfileService = UserProfileService();

  final TextEditingController _commentController = TextEditingController();
  int _rating = 3;

  @override
  void initState() {
    super.initState();
    _feedbackService.init();
    _userProfileService.init();
  }

  void _submitFeedback() async {
    final userProfile = _userProfileService.userProfile;
    if (userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, настройте профиль пользователя')),
      );
      return;
    }

    final feedback = FeedbackModel(
      id: const Uuid().v4(),
      userId: userProfile.id,
      analysisId: 'analysis123', // Замените на актуальный ID анализа
      comment: _commentController.text.trim(),
      rating: _rating,
      timestamp: DateTime.now(),
    );

    await _feedbackService.insertFeedback(feedback);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Спасибо за ваш отзыв!')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Оставить Отзыв'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Оцените расшифровку анализов:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _rating.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '$_rating',
                onChanged: (double value) {
                  setState(() {
                    _rating = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Ваш комментарий:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Напишите ваш отзыв здесь',
                ),
                maxLines: 4,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text('Отправить Отзыв'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ));
  }
}
