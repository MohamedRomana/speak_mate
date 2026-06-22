import '../../../../core/constants/app_constants.dart';
import '../../../../core/networking/api_constants.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/networking/api_service.dart';
import '../../../users/patient/dashboard/data/models/session_model.dart';
import '../models/rehab_models.dart';

/// مستودع وحدة الكبار (إعادة التأهيل) — mock + ربط API حقيقي خلف الفلاج.
class AdultRepo {
  final ApiService _api;
  AdultRepo({ApiService? api}) : _api = api ?? ApiService();

  /// جلسات البالغ مع الأخصائي (مكالمات فيديو/صوت) — قادمة وسابقة.
  Future<ApiResult<List<SessionModel>>> getSessions() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        final now = DateTime.now();
        return ApiResult.success([
          SessionModel(
            id: 'as1',
            title: 'جلسة علاج النطق',
            therapistName: 'د. سارة المهدي',
            dateTime: now.add(const Duration(hours: 4)),
            type: SessionType.individual,
            status: SessionStatus.upcoming,
            mode: SessionMode.videoCall,
            durationMinutes: 45,
          ),
          SessionModel(
            id: 'as2',
            title: 'تقييم الطلاقة',
            therapistName: 'د. خالد العتيبي',
            dateTime: now.add(const Duration(days: 2, hours: 1)),
            type: SessionType.individual,
            status: SessionStatus.upcoming,
            mode: SessionMode.voiceCall,
            durationMinutes: 30,
          ),
          SessionModel(
            id: 'as3',
            title: 'جلسة الكلام البطيء',
            therapistName: 'د. سارة المهدي',
            dateTime: now.subtract(const Duration(days: 3)),
            type: SessionType.individual,
            status: SessionStatus.completed,
            mode: SessionMode.videoCall,
            durationMinutes: 45,
            score: 82,
          ),
        ]);
      }
      return ApiService.executeApi<List<SessionModel>>(
        () => _api.get(ApiConstants.sessions, query: {'role': 'adult'}),
        parser: (data) => (data as List)
            .map((e) => SessionModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// نسبة تقدّم التعافي الكلية ومتوسط الدقة وعدد جلسات الأسبوع.
  int get recoveryProgress => 68;
  int get avgAccuracy => 74;
  int get weeklySessions => 4;

  Future<ApiResult<List<RehabModule>>> getModules() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success([
          RehabModule(type: RehabType.slowSpeech, progress: 80),
          RehabModule(type: RehabType.pronunciation, progress: 65),
          RehabModule(type: RehabType.language, progress: 45),
          RehabModule(type: RehabType.memory, progress: 30),
        ]);
      }
      return ApiService.executeApi<List<RehabModule>>(
        () => _api.get('${ApiConstants.exercises}/rehab'),
        parser: (data) => (data as List)
            .map((e) => RehabModule.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// عبارات/كلمات التمرين حسب نوع الوحدة.
  List<RehabPhrase> phrases(RehabType type) {
    switch (type) {
      case RehabType.slowSpeech:
        return const [
          RehabPhrase('صَباح الخير'),
          RehabPhrase('كيف حالك اليوم'),
          RehabPhrase('أنا بخير والحمد لله'),
          RehabPhrase('أريد كوب ماء من فضلك'),
        ];
      case RehabType.pronunciation:
        return const [
          RehabPhrase('شَمس'),
          RehabPhrase('قَمَر'),
          RehabPhrase('سيّارة'),
          RehabPhrase('مدينة'),
          RehabPhrase('طبيب'),
        ];
      case RehabType.language:
        return const [
          RehabPhrase('الكتاب على الطاولة'),
          RehabPhrase('الطقس جميل اليوم'),
          RehabPhrase('أحبّ القراءة في الصباح'),
          RehabPhrase('سأزور العائلة غدًا'),
        ];
      case RehabType.memory:
        return const [
          RehabPhrase('تفاحة موز برتقال'),
          RehabPhrase('باب نافذة كرسي'),
          RehabPhrase('أحمر أزرق أخضر'),
          RehabPhrase('واحد اثنان ثلاثة'),
        ];
    }
  }
}
