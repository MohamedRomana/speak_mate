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

  // ---- الرئيسية (placeholders للمراحل القادمة) ----
  static const String patientHome = '/patientHome';
  static const String therapistHome = '/therapistHome';
}
