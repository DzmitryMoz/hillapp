// lib/screens/view_feedback_screen.dart

import 'package:flutter/material.dart';
import '../models/feedback.dart';
import '../services/feedback_service.dart';

class ViewFeedbackScreen extends StatefulWidget {
  const ViewFeedbackScreen({Key? key}) : super(key: key);

  @override
  _ViewFeedbackScreenState createState() => _ViewFeedbackScreenState();
}

class _ViewFeedbackScreenState extends State<ViewFeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  bool _isLoading = true;
  List<FeedbackModel> _feedbacks = [];

  @override
  void initState() {
    super.initState();
    _feedbackService.init().then((_) {
      _loadFeedbacks();
    });
  }

  Future<void> _loadFeedbacks() async {
    // Замените 'analysis123' на актуальный ID анализа или получите его динамически
    final feedbacks = await _feedbackService.getFeedbackForAnalysis('analysis123');
    setState(() {
      _feedbacks = feedbacks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отзывы'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feedbacks.isEmpty
          ? const Center(child: Text('Нет отзывов для этого анализа.'))
          : ListView.builder(
        itemCount: _feedbacks.length,
        itemBuilder: (context, index) {
          final FeedbackModel feedback = _feedbacks[index];
          return ListTile(
            leading: Icon(
              Icons.star,
              color: Colors.amber,
              size: 24,
            ),
            title: Text('${feedback.rating}/5'),
            subtitle: Text(feedback.comment),
            trailing: Text(
              '${feedback.timestamp.day}.${feedback.timestamp.month}.${feedback.timestamp.year}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
