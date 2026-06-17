/// ثوابت عامة لتطبيق SpeakMate + إعدادات الـ mock.
class AppConstants {
  AppConstants._();

  /// لو true التطبيق يشتغل ببيانات وهمية (mock) من غير باك إند.
  /// غيّرها لـ false لما يجهز الـ API الحقيقي عشان يبدأ يكلّم السيرفر.
  static const bool useMockData = true;

  /// تأخير وهمي لمحاكاة الـ network وإظهار حالات التحميل.
  static const Duration mockDelay = Duration(milliseconds: 1200);

  /// رمز التحقق الثابت في وضع الـ mock.
  static const String mockOtp = '123456';

  /// مدة إعادة إرسال رمز التحقق (ثواني).
  static const int otpResendSeconds = 60;

  /// الحد الأدنى لطول كلمة المرور.
  static const int minPasswordLength = 8;

  /// أنواع صعوبات التواصل المتاحة للاختيار في ملف المتدرّب.
  static const List<String> difficultyTypes = [
    'difficultySpeech',
    'difficultyHearing',
    'difficultyArticulation',
  ];
}

/// قيم نوع المستخدم المخزّنة في `CacheHelper.getUserType()`.
class UserTypes {
  UserTypes._();
  static const String patient = 'patient'; // ولي أمر / طفل (وحدة الطفل)
  static const String adult = 'adult'; // مريض بالغ (إعادة التأهيل)
  static const String therapist = 'therapist'; // أخصائي تخاطب
  static const String clinic = 'clinic'; // مدير عيادة
}
