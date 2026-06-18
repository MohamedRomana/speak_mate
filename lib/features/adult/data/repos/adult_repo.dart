import '../../../../core/constants/app_constants.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../models/rehab_models.dart';

/// مستودع وحدة الكبار (إعادة التأهيل) — mock.
class AdultRepo {
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
      throw UnimplementedError('Real API not wired yet');
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
