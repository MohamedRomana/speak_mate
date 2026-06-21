import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/networking/api_constants.dart';
import '../../../../../../core/networking/api_error_model.dart';
import '../../../../../../core/networking/api_result.dart';
import '../../../../../../core/networking/api_service.dart';
import '../models/report_data.dart';

/// مستودع تقارير التقدّم — mock + ربط API حقيقي خلف الفلاج.
class ReportsRepo {
  final ApiService _api;
  ReportsRepo({ApiService? api}) : _api = api ?? ApiService();

  Future<ApiResult<ReportData>> getReport(
    ReportPeriod period,
    String lang,
  ) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        return ApiResult.success(
          period == ReportPeriod.week
              ? _week(lang)
              : _month(lang),
        );
      }
      return ApiService.executeApi<ReportData>(
        () => _api.get(ApiConstants.progress, query: {'range': period.name}),
        parser: (data) =>
            ReportData.fromJson((data as Map).cast<String, dynamic>(), period),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  ReportData _week(String lang) {
    final days = lang == 'en'
        ? ['Sa', 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr']
        : ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
    return ReportData(
      period: ReportPeriod.week,
      totalSessions: 5,
      totalExercises: 24,
      avgAccuracy: 79,
      streak: 6,
      accuracySeries: const [62, 68, 70, 74, 76, 80, 82],
      completionSeries: const [80, 100, 60, 100, 40, 100, 90],
      axisLabels: days,
      skills: ReportData.defaultSkills,
    );
  }

  ReportData _month(String lang) {
    final weeks = lang == 'en'
        ? ['W1', 'W2', 'W3', 'W4']
        : ['أ١', 'أ٢', 'أ٣', 'أ٤'];
    return ReportData(
      period: ReportPeriod.month,
      totalSessions: 19,
      totalExercises: 96,
      avgAccuracy: 84,
      streak: 21,
      accuracySeries: const [70, 76, 81, 86],
      completionSeries: const [72, 85, 90, 96],
      axisLabels: weeks,
      skills: const [
        SkillScore(labelKey: 'skillPronunciation', value: 0.88),
        SkillScore(labelKey: 'skillVocabulary', value: 0.79),
        SkillScore(labelKey: 'skillFluency', value: 0.72),
        SkillScore(labelKey: 'skillComprehension', value: 0.85),
      ],
    );
  }
}
