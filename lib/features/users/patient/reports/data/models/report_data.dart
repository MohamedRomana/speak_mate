import '../../../../../../generated/locale_keys.g.dart';

enum ReportPeriod { week, month }

/// مهارة + نسبة إتقانها (0..1).
class SkillScore {
  final String labelKey;
  final double value;
  const SkillScore({required this.labelKey, required this.value});

  factory SkillScore.fromJson(Map<String, dynamic> json) => SkillScore(
        labelKey: (json['label_key'] ?? json['label'] ?? '').toString(),
        value: double.tryParse('${json['value']}') ?? 0,
      );
}

/// بيانات تقرير التقدّم لفترة.
class ReportData {
  final ReportPeriod period;
  final int totalSessions;
  final int totalExercises;
  final int avgAccuracy; // %
  final int streak;
  final List<double> accuracySeries; // نقاط دقة (0..100)
  final List<double> completionSeries; // نسب إكمال لكل عمود (0..100)
  final List<String> axisLabels; // تسميات المحور السيني
  final List<SkillScore> skills;

  const ReportData({
    required this.period,
    required this.totalSessions,
    required this.totalExercises,
    required this.avgAccuracy,
    required this.streak,
    required this.accuracySeries,
    required this.completionSeries,
    required this.axisLabels,
    required this.skills,
  });

  static const defaultSkills = [
    SkillScore(labelKey: LocaleKeys.skillPronunciation, value: 0.82),
    SkillScore(labelKey: LocaleKeys.skillVocabulary, value: 0.7),
    SkillScore(labelKey: LocaleKeys.skillFluency, value: 0.64),
    SkillScore(labelKey: LocaleKeys.skillComprehension, value: 0.78),
  ];

  factory ReportData.fromJson(Map<String, dynamic> json, ReportPeriod period) {
    List<double> nums(dynamic v) =>
        (v as List? ?? []).map((e) => double.tryParse('$e') ?? 0).toList();
    return ReportData(
      period: period,
      totalSessions: int.tryParse('${json['total_sessions']}') ?? 0,
      totalExercises: int.tryParse('${json['total_exercises']}') ?? 0,
      avgAccuracy: int.tryParse('${json['avg_accuracy']}') ?? 0,
      streak: int.tryParse('${json['streak']}') ?? 0,
      accuracySeries: nums(json['accuracy_series']),
      completionSeries: nums(json['completion_series']),
      axisLabels: (json['axis_labels'] as List? ?? []).map((e) => '$e').toList(),
      skills: (json['skills'] as List? ?? [])
          .map((e) => SkillScore.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}
