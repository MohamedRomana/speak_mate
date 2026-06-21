import '../../../../../../core/cache/cache_helper.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/networking/api_constants.dart';
import '../../../../../../core/networking/api_error_model.dart';
import '../../../../../../core/networking/api_result.dart';
import '../../../../../../core/networking/api_service.dart';
import '../models/patient_profile.dart';
import '../models/recording_model.dart';

/// مستودع ملف المتدرّب — mock + ربط API حقيقي خلف الفلاج.
class ProfileRepo {
  final ApiService _api;
  ProfileRepo({ApiService? api}) : _api = api ?? ApiService();

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
      return ApiService.executeApi<PatientProfile>(
        () => _api.get(ApiConstants.me),
        parser: (data) => PatientProfile.fromJson((data as Map).cast<String, dynamic>()),
      );
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
      return ApiService.executeApi<List<Recording>>(
        () => _api.get(ApiConstants.recordings),
        parser: (data) => (data as List)
            .map((e) => Recording.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
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
      final res = await ApiService.executeApi<PatientProfile>(
        () => _api.put(ApiConstants.updateMe, data: profile.toJson()),
        parser: (data) => PatientProfile.fromJson((data as Map).cast<String, dynamic>()),
      );
      if (res is Success<PatientProfile>) {
        await CacheHelper.setUserName(res.data.name);
      }
      return res;
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }
}
