enum SessionType { individual, group }

enum SessionStatus { upcoming, completed }

/// جلسة علاجية (mock).
class SessionModel {
  final String id;
  final String title;
  final String therapistName;
  final DateTime dateTime;
  final SessionType type;
  final SessionStatus status;
  final int durationMinutes;

  /// نتيجة الجلسة المكتملة (0..100)، null للقادمة.
  final int? score;

  const SessionModel({
    required this.id,
    required this.title,
    required this.therapistName,
    required this.dateTime,
    required this.type,
    required this.status,
    required this.durationMinutes,
    this.score,
  });
}
