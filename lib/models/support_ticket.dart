// lib/models/support_ticket.dart

class SupportTicket {
  final String id;
  final String userId;
  final String subject;
  final String message;
  final DateTime timestamp;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    required this.timestamp,
  });

  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      id: map['id'],
      userId: map['userId'],
      subject: map['subject'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
