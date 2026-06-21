/// نوع التسجيل.
enum RecordingType { audio, video }

/// تسجيل صوتي/فيديو مرفوع لتمرين (mock — مسار محلي أو وهمي).
class Recording {
  final String id;
  final RecordingType type;
  final String title;
  final int durationSeconds;
  final String dateLabel;
  final String? path;

  const Recording({
    required this.id,
    required this.type,
    required this.title,
    required this.durationSeconds,
    required this.dateLabel,
    this.path,
  });

  String get durationLabel {
    final m = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  factory Recording.fromJson(Map<String, dynamic> json) => Recording(
        id: (json['id'] ?? '').toString(),
        type: '${json['type']}' == 'video'
            ? RecordingType.video
            : RecordingType.audio,
        title: (json['title'] ?? '').toString(),
        durationSeconds: int.tryParse('${json['duration_seconds'] ?? json['duration']}') ?? 0,
        dateLabel: (json['date_label'] ?? json['date'] ?? '').toString(),
        path: json['path']?.toString() ?? json['url']?.toString(),
      );
}
