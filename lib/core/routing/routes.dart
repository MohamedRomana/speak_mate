/// أسماء مسارات SpeakMate. أي route جديد: ضِف const هنا + case في [AppRouter].
class Routes {
  Routes._();

  // ---- البداية ----
  static const String splash = '/splash';
  static const String language = '/language';
  static const String onBoarding = '/onBoarding';
  static const String roleSelection = '/roleSelection';

  // ---- المصادقة ----
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgotPassword';
  static const String otpVerification = '/otpVerification';
  static const String resetPassword = '/resetPassword';

  // ---- الرئيسية لكل وحدة ----
  static const String patientHome = '/patientHome'; // وحدة الطفل
  static const String adultHome = '/adultHome'; // وحدة الكبار
  static const String therapistHome = '/therapistHome'; // الأخصائي
  static const String clinicHome = '/clinicHome'; // العيادة
}
