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

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      therapistName: (json['therapist_name'] ?? json['therapist'] ?? '').toString(),
      dateTime: DateTime.tryParse('${json['date_time'] ?? json['datetime'] ?? ''}') ??
          DateTime.now(),
      type: '${json['type']}' == 'group' ? SessionType.group : SessionType.individual,
      status: '${json['status']}' == 'completed'
          ? SessionStatus.completed
          : SessionStatus.upcoming,
      durationMinutes: int.tryParse('${json['duration_minutes'] ?? json['duration']}') ?? 30,
      score: json['score'] == null ? null : int.tryParse('${json['score']}'),
    );
  }
}
