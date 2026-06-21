enum PatientCondition { child, adult }

/// إحصاء صوت ضعيف لمريض (للخريطة الحرارية في لوحة الأخصائي).
class WeakSoundStat {
  final String sound; // الحرف العربي
  final double errorRate; // 0..1 نسبة الخطأ على هذا الصوت
  const WeakSoundStat(this.sound, this.errorRate);
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
}
