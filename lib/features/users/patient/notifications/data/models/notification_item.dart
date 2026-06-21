enum NotificationType { reminder, exercise, motivation, achievement, appointment, plan }

extension NotificationTypeX on NotificationType {
  String get key => name;
  static NotificationType fromKey(String? k) => NotificationType.values.firstWhere(
        (e) => e.name == k,
        orElse: () => NotificationType.reminder,
      );
}

/// عنصر إشعار (mock).
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String timeLabel;
  final bool read;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timeLabel,
    this.read = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: (json['id'] ?? '').toString(),
        type: NotificationTypeX.fromKey(json['type']?.toString()),
        title: (json['title'] ?? '').toString(),
        body: (json['body'] ?? json['message'] ?? '').toString(),
        timeLabel: (json['time_label'] ?? json['time'] ?? '').toString(),
        read: json['read'] == true || json['is_read'] == true,
      );

  NotificationItem copyWith({bool? read}) => NotificationItem(
        id: id,
        type: type,
        title: title,
        body: body,
        timeLabel: timeLabel,
        read: read ?? this.read,
      );
}
