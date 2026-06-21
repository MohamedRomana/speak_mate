/// حالة الخطة العلاجية.
enum PlanStatus { draft, active, completed }

extension PlanStatusX on PlanStatus {
  String get key => name;
  static PlanStatus fromKey(String? k) => PlanStatus.values.firstWhere(
        (e) => e.name == k,
        orElse: () => PlanStatus.draft,
      );
}

/// هدف أسبوعي داخل الخطة (فئة تمارين + العدد المستهدف).
class PlanTarget {
  final String titleKey; // مفتاح ترجمة أو نص
  final String emoji;
  final int targetCount;
  final int doneCount;

  const PlanTarget({
    required this.titleKey,
    required this.emoji,
    required this.targetCount,
    this.doneCount = 0,
  });

  double get ratio => targetCount == 0 ? 0 : (doneCount / targetCount).clamp(0, 1);

  factory PlanTarget.fromJson(Map<String, dynamic> json) => PlanTarget(
        titleKey: (json['title_key'] ?? json['title'] ?? '').toString(),
        emoji: (json['emoji'] ?? '🎯').toString(),
        targetCount: int.tryParse('${json['target_count']}') ?? 0,
        doneCount: int.tryParse('${json['done_count']}') ?? 0,
      );
}

/// خطة/برنامج علاجي — قالب يصمّمه الأخصائي ويُسنَد للمريض.
class TherapyPlan {
  final String id;
  final String title;
  final String goal; // وصف الهدف العام
  final List<String> targetSounds; // الفونيمات المستهدفة (حروف)
  final int durationWeeks;
  final int sessionsPerWeek;
  final List<PlanTarget> targets;
  final PlanStatus status;
  final int progress; // 0..100 (للخطة المُسنَدة)

  const TherapyPlan({
    required this.id,
    required this.title,
    required this.goal,
    this.targetSounds = const [],
    this.durationWeeks = 4,
    this.sessionsPerWeek = 3,
    this.targets = const [],
    this.status = PlanStatus.draft,
    this.progress = 0,
  });

  int get weeklyMinutes => sessionsPerWeek * 20;

  TherapyPlan copyWith({PlanStatus? status, int? progress}) => TherapyPlan(
        id: id,
        title: title,
        goal: goal,
        targetSounds: targetSounds,
        durationWeeks: durationWeeks,
        sessionsPerWeek: sessionsPerWeek,
        targets: targets,
        status: status ?? this.status,
        progress: progress ?? this.progress,
      );

  factory TherapyPlan.fromJson(Map<String, dynamic> json) => TherapyPlan(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        goal: (json['goal'] ?? json['description'] ?? '').toString(),
        targetSounds:
            (json['target_sounds'] as List? ?? []).map((e) => '$e').toList(),
        durationWeeks: int.tryParse('${json['duration_weeks']}') ?? 4,
        sessionsPerWeek: int.tryParse('${json['sessions_per_week']}') ?? 3,
        targets: (json['targets'] as List? ?? [])
            .map((e) => PlanTarget.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        status: PlanStatusX.fromKey(json['status']?.toString()),
        progress: int.tryParse('${json['progress']}') ?? 0,
      );
}
