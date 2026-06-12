enum NotificationType { reminder, exercise, motivation, achievement }

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

  NotificationItem copyWith({bool? read}) => NotificationItem(
        id: id,
        type: type,
        title: title,
        body: body,
        timeLabel: timeLabel,
        read: read ?? this.read,
      );
}
