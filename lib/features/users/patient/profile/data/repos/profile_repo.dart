import '../../../../../../core/cache/cache_helper.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/networking/api_error_model.dart';
import '../../../../../../core/networking/api_result.dart';
import '../models/patient_profile.dart';
import '../models/recording_model.dart';

/// مستودع ملف المتدرّب — mock. يرجّع [ApiResult] ليسهل ربطه بـ API لاحقًا.
class ProfileRepo {
  Future<ApiResult<PatientProfile>> getProfile() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        final name = CacheHelper.getUserName();
        return ApiResult.success(
          PatientProfile(
            id: CacheHelper.getUserId(),
            name: name.isEmpty ? 'أحمد محمد' : name,
            email: 'ahmed@speakmate.com',
            phone: '0551234567',
            age: 8,
            gender: 'male',
            difficultyType: 'difficultySpeech',
            notes: 'يتحسّن في نطق حرف الراء، يحتاج تمارين إضافية على السين.',
          ),
        );
      }
      throw UnimplementedError('Real API not wired yet');
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  Future<ApiResult<List<Recording>>> getRecordings() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success([
          Recording(
            id: 'r1',
            type: RecordingType.audio,
            title: 'تمرين حرف الراء',
            durationSeconds: 47,
            dateLabel: '2026/06/10',
          ),
          Recording(
            id: 'r2',
            type: RecordingType.video,
            title: 'قراءة جملة كاملة',
            durationSeconds: 132,
            dateLabel: '2026/06/08',
          ),
          Recording(
            id: 'r3',
            type: RecordingType.audio,
            title: 'نطق الأرقام 1-10',
            durationSeconds: 65,
            dateLabel: '2026/06/05',
          ),
        ]);
      }
      throw UnimplementedError('Real API not wired yet');
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  Future<ApiResult<PatientProfile>> updateProfile(
    PatientProfile profile,
  ) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        await CacheHelper.setUserName(profile.name);
        return ApiResult.success(profile);
      }
      throw UnimplementedError('Real API not wired yet');
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }
}
