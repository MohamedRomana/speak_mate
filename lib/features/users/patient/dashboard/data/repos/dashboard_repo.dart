import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/networking/api_constants.dart';
import '../../../../../../core/networking/api_error_model.dart';
import '../../../../../../core/networking/api_result.dart';
import '../../../../../../core/networking/api_service.dart';
import '../models/dashboard_data.dart';
import '../models/session_model.dart';

/// مستودع لوحة المتدرّب — mock + ربط API حقيقي خلف الفلاج.
class DashboardRepo {
  final ApiService _api;
  DashboardRepo({ApiService? api}) : _api = api ?? ApiService();

  Future<ApiResult<DashboardData>> getDashboard() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        final now = DateTime.now();
        return ApiResult.success(
          DashboardData(
            motivationKey: 'motivation2',
            streakDays: 6,
            sessionsCompleted: 18,
            accuracy: 82,
            accuracySeries: const [55, 60, 58, 67, 72, 78, 82],
            upcoming: [
              SessionModel(
                id: 's1',
                title: 'تمارين مخارج الحروف',
                therapistName: 'د. سارة المهدي',
                dateTime: now.add(const Duration(hours: 5)),
                type: SessionType.individual,
                status: SessionStatus.upcoming,
                mode: SessionMode.videoCall,
                durationMinutes: 30,
              ),
              SessionModel(
                id: 's2',
                title: 'جلسة المحادثة',
                therapistName: 'د. خالد العتيبي',
                dateTime: now.add(const Duration(days: 1, hours: 2)),
                type: SessionType.individual,
                status: SessionStatus.upcoming,
                mode: SessionMode.voiceCall,
                durationMinutes: 45,
              ),
            ],
            completed: [
              SessionModel(
                id: 's3',
                title: 'نطق حرف الراء',
                therapistName: 'د. سارة المهدي',
                dateTime: now.subtract(const Duration(days: 2)),
                type: SessionType.individual,
                status: SessionStatus.completed,
                durationMinutes: 30,
                score: 88,
              ),
              SessionModel(
                id: 's4',
                title: 'تمارين المفردات',
                therapistName: 'د. سارة المهدي',
                dateTime: now.subtract(const Duration(days: 5)),
                type: SessionType.individual,
                status: SessionStatus.completed,
                durationMinutes: 30,
                score: 75,
              ),
            ],
          ),
        );
      }
      return ApiService.executeApi<DashboardData>(
        () => _api.get(ApiConstants.dashboard),
        parser: (data) => DashboardData.fromJson((data as Map).cast<String, dynamic>()),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }
}
