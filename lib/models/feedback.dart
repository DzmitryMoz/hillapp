// lib/models/feedback.dart

class FeedbackModel {
  final String id;
  final String userId;
  final String analysisId;
  final String comment;
  final int rating;
  final DateTime timestamp;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.analysisId,
    required this.comment,
    required this.rating,
    required this.timestamp,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'],
      userId: map['userId'],
      analysisId: map['analysisId'],
      comment: map['comment'],
      rating: map['rating'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'analysisId': analysisId,
      'comment': comment,
      'rating': rating,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
