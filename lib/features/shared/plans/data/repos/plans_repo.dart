import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/networking/api_constants.dart';
import '../../../../../core/networking/api_error_model.dart';
import '../../../../../core/networking/api_result.dart';
import '../../../../../core/networking/api_service.dart';
import '../models/therapy_plan.dart';

/// مستودع الخطط العلاجية — قوالب يصمّمها الأخصائي، إسناد للمريض، وخطة المريض
/// الحالية. mock + ربط API حقيقي خلف الفلاج.
class PlansRepo {
  final ApiService _api;
  PlansRepo({ApiService? api}) : _api = api ?? ApiService();

  /// قوالب الخطط الجاهزة (يختار منها الأخصائي عند الإسناد).
  Future<ApiResult<List<TherapyPlan>>> getTemplates() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success(_templates);
      }
      return ApiService.executeApi<List<TherapyPlan>>(
        () => _api.get(ApiConstants.plans),
        parser: (data) => (data as List)
            .map((e) => TherapyPlan.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// إسناد خطة لمريض.
  Future<ApiResult<bool>> assignPlan({
    required String patientId,
    required String planId,
  }) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success(true);
      }
      return ApiService.executeApi<bool>(
        () => _api.post(ApiConstants.patientPlan(patientId), data: {'plan_id': planId}),
        parser: (_) => true,
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// الخطة الحالية للمريض المُسجَّل (جانب المتدرّب).
  Future<ApiResult<TherapyPlan?>> getMyPlan() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 700));
        return const ApiResult.success(_activePlan);
      }
      return ApiService.executeApi<TherapyPlan?>(
        () => _api.get('${ApiConstants.me}/plan'),
        parser: (data) => data == null
            ? null
            : TherapyPlan.fromJson((data as Map).cast<String, dynamic>()),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  // ----------------------- بيانات mock -----------------------

  static const _templates = [
    TherapyPlan(
      id: 'p_r',
      title: 'برنامج حرف الراء',
      goal: 'تحسين نطق صوت الراء عبر تمارين تدريجية مكثّفة',
      targetSounds: ['ر', 'ل'],
      durationWeeks: 4,
      sessionsPerWeek: 4,
      targets: [
        PlanTarget(titleKey: 'تمارين تكرار', emoji: '🔁', targetCount: 12),
        PlanTarget(titleKey: 'مطابقة أصوات', emoji: '🎯', targetCount: 8),
        PlanTarget(titleKey: 'جلسات مع الأخصائي', emoji: '👩‍⚕️', targetCount: 4),
      ],
    ),
    TherapyPlan(
      id: 'p_s',
      title: 'برنامج الصفير (س/ث/ص)',
      goal: 'تصحيح أصوات الصفير وتمييزها سمعيًا',
      targetSounds: ['س', 'ث', 'ص'],
      durationWeeks: 6,
      sessionsPerWeek: 3,
      targets: [
        PlanTarget(titleKey: 'تمارين تكرار', emoji: '🔁', targetCount: 18),
        PlanTarget(titleKey: 'ألعاب نطق', emoji: '🎮', targetCount: 10),
      ],
    ),
    TherapyPlan(
      id: 'p_lang',
      title: 'تنمية المفردات واللغة',
      goal: 'توسيع الحصيلة اللغوية وبناء الجُمل',
      targetSounds: [],
      durationWeeks: 8,
      sessionsPerWeek: 3,
      targets: [
        PlanTarget(titleKey: 'مفردات جديدة', emoji: '📚', targetCount: 40),
        PlanTarget(titleKey: 'تسمية صور', emoji: '🖼️', targetCount: 20),
      ],
    ),
  ];

  static const _activePlan = TherapyPlan(
    id: 'p_r',
    title: 'برنامج حرف الراء',
    goal: 'تحسين نطق صوت الراء عبر تمارين تدريجية مكثّفة',
    targetSounds: ['ر', 'ل'],
    durationWeeks: 4,
    sessionsPerWeek: 4,
    status: PlanStatus.active,
    progress: 45,
    targets: [
      PlanTarget(titleKey: 'تمارين تكرار', emoji: '🔁', targetCount: 12, doneCount: 7),
      PlanTarget(titleKey: 'مطابقة أصوات', emoji: '🎯', targetCount: 8, doneCount: 3),
      PlanTarget(titleKey: 'جلسات مع الأخصائي', emoji: '👩‍⚕️', targetCount: 4, doneCount: 1),
    ],
  );
}
