import 'session_model.dart';

/// حزمة بيانات لوحة المتدرّب.
class DashboardData {
  final String motivationKey; // مفتاح رسالة تحفيزية
  final int streakDays;
  final int sessionsCompleted;
  final int accuracy; // %
  final List<double> accuracySeries; // آخر 7 نقاط (0..100)
  final List<SessionModel> upcoming;
  final List<SessionModel> completed;

  const DashboardData({
    required this.motivationKey,
    required this.streakDays,
    required this.sessionsCompleted,
    required this.accuracy,
    required this.accuracySeries,
    required this.upcoming,
    required this.completed,
  });
}
