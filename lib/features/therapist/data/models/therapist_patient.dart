enum PatientCondition { child, adult }

/// إحصاء صوت ضعيف لمريض (للخريطة الحرارية في لوحة الأخصائي).
class WeakSoundStat {
  final String sound; // الحرف العربي
  final double errorRate; // 0..1 نسبة الخطأ على هذا الصوت
  const WeakSoundStat(this.sound, this.errorRate);

  factory WeakSoundStat.fromJson(Map<String, dynamic> json) => WeakSoundStat(
        (json['sound'] ?? '').toString(),
        double.tryParse('${json['error_rate']}') ?? 0,
      );
}

/// تسجيل مريض (لمراجعة الأخصائي).
class PatientRecording {
  final String id;
  final String title;
  final int durationSeconds;
  final int accuracy; // %
  final String dateLabel;

  const PatientRecording({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.accuracy,
    required this.dateLabel,
  });

  String get durationLabel {
    final m = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  factory PatientRecording.fromJson(Map<String, dynamic> json) => PatientRecording(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        durationSeconds: int.tryParse('${json['duration_seconds'] ?? json['duration']}') ?? 0,
        accuracy: int.tryParse('${json['accuracy']}') ?? 0,
        dateLabel: (json['date_label'] ?? json['date'] ?? '').toString(),
      );
}

/// مريض في لوحة الأخصائي.
class TherapistPatient {
  final String id;
  final String name;
  final int age;
  final PatientCondition condition;
  final int progress; // 0..100
  final int accuracy; // %
  final String lastActive;
  final List<double> accuracySeries;
  final List<WeakSoundStat> weakSounds;
  final List<PatientRecording> recordings;

  const TherapistPatient({
    required this.id,
    required this.name,
    required this.age,
    required this.condition,
    required this.progress,
    required this.accuracy,
    required this.lastActive,
    this.accuracySeries = const [],
    this.weakSounds = const [],
    this.recordings = const [],
  });

  bool get isChild => condition == PatientCondition.child;

  factory TherapistPatient.fromJson(Map<String, dynamic> json) => TherapistPatient(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        age: int.tryParse('${json['age']}') ?? 0,
        condition: '${json['condition']}' == 'adult'
            ? PatientCondition.adult
            : PatientCondition.child,
        progress: int.tryParse('${json['progress']}') ?? 0,
        accuracy: int.tryParse('${json['accuracy']}') ?? 0,
        lastActive: (json['last_active'] ?? '').toString(),
        accuracySeries: (json['accuracy_series'] as List? ?? [])
            .map((e) => double.tryParse('$e') ?? 0)
            .toList(),
        weakSounds: (json['weak_sounds'] as List? ?? [])
            .map((e) => WeakSoundStat.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        recordings: (json['recordings'] as List? ?? [])
            .map((e) => PatientRecording.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}
