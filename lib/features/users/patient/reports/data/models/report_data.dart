import '../../../../../../generated/locale_keys.g.dart';

enum ReportPeriod { week, month }

/// مهارة + نسبة إتقانها (0..1).
class SkillScore {
  final String labelKey;
  final double value;
  const SkillScore({required this.labelKey, required this.value});
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
}
