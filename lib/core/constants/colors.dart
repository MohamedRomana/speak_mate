import 'dart:ui';

/// هوية ألوان SpeakMate — "Serene" palette: أزرق سماوي هادئ + لافندر بنفسجي +
/// نعناعي. ألوان هادئة ومطمئِنة مناسبة لتطبيق تخاطب للأطفال والكبار.
///
/// ألوان الـ brand الثابتة تبقى `const`. أما ألوان الأسطح (الخلفية/الكارت/النص/
/// الحدود) فهي getters تتبدّل حسب الثيم عبر [isDark] الذي يُضبط من سطوع الثيم
/// الفعّال في `MaterialApp.builder`.
abstract class AppColors {
  /// يُضبط من `MaterialApp.builder` حسب الثيم الفعّال (يدعم وضع النظام أيضًا).
  static bool isDark = false;

  /// وضع التباين العالي (إمكانية الوصول) — يُضبط من SettingsCubit.
  static bool highContrast = false;

  // ---- Brand (ثابتة) ----
  /// الأساسي — أزرق سماوي هادئ.
  static const Color primary = Color(0xff4F8DFB);
  static const Color primaryDark = Color(0xff3A6FE0);

  /// الثانوي — لافندر بنفسجي ناعم.
  static const Color secondary = Color(0xff9B7EDE);
  static const Color secondaryDark = Color(0xff7C5FD0);

  /// التمييز — نعناعي.
  static const Color accent = Color(0xff34C7A6);

  /// خلفية داكنة عميقة.
  static const Color deepBg = Color(0xff0E1726);

  // ---- حالات ----
  static const Color success = Color(0xff34C7A6);
  static const Color warning = Color(0xffF6B445);
  static const Color error = Color(0xffEF6B6B);

  // ---- أسطح متبدّلة حسب الثيم ----
  static Color get scaffoldBg =>
      isDark ? deepBg : const Color(0xffF5F8FF);
  static Color get card =>
      isDark ? const Color(0xff16223C) : const Color(0xffFFFFFF);
  static Color get cardAlt =>
      isDark ? const Color(0xff1B2A47) : const Color(0xffF1F5FF);
  static Color get mainText => highContrast
      ? (isDark ? const Color(0xffFFFFFF) : const Color(0xff000000))
      : (isDark ? const Color(0xffEAF1FB) : const Color(0xff142033));
  static Color get secondaryText => highContrast
      ? (isDark ? const Color(0xffC7D2E0) : const Color(0xff39414D))
      : (isDark ? const Color(0xff93A4BC) : const Color(0xff64708A));
  static Color get border => highContrast
      ? (isDark ? const Color(0xff4A5E80) : const Color(0xff9AA7B8))
      : (isDark ? const Color(0xff243352) : const Color(0xffE6EBF4));

  /// خلفيات ناعمة ملوّنة (للأيقونات/الشارات/البطاقات المميّزة).
  static Color get softPrimary =>
      isDark ? const Color(0x334F8DFB) : const Color(0xffE9F1FF);
  static Color get softSecondary =>
      isDark ? const Color(0x339B7EDE) : const Color(0xffF1ECFC);
  static Color get softAccent =>
      isDark ? const Color(0x3334C7A6) : const Color(0xffE3F7F1);

  // ---- Legacy aliases (تُستخدم في core widgets المشتركة — لا تحذفها) ----
  // ملاحظة: الأسماء القديمة (navy/orange) من قالب آخر؛ أعيد توجيه قيمها لهوية
  // SpeakMate حتى تستمر الـ widgets العامة بالعمل دون تعديل.
  static const Color navy = Color(0xff1E2A4A); // brand غامق (نص فوق الخلفيات)
  static const Color navy2 = Color(0xff2C3E6B);
  static const Color orange = primary; // كان لون CTA → الآن أزرق
  static const Color orange2 = Color(0xff6FA3FF);
  static const Color secondray = navy;
  static const Color darkRed = error;
  static const Color thirdColor = navy;

  static Color get lightBg => scaffoldBg;
  static Color get backColor => scaffoldBg;
  static Color get fourthColor => scaffoldBg;
  static Color get textColor => mainText;
  static Color get textColor2 => secondaryText;
  static Color get borderColor => border;
  static Color get softOrange => softPrimary;
}
