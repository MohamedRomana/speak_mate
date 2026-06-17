import 'dart:ui';

import 'package:flutter/foundation.dart';

/// هوية ألوان VoiceBridge AI — Indigo + Cyan + Green + Amber (Dark-first).
/// نظام طبي/ذكاء اصطناعي حديث: ودود للأطفال واحترافي للكبار والأخصائيين.
///
/// ألوان الأسطح getters تتبدّل حسب [isDark]/[highContrast]. أي تغيير فيهما يُخطر
/// [uiNotifier] فتُعيد كل الشاشات (الملفوفة بـ ValueListenableBuilder في الراوتر)
/// بناء نفسها فورًا — فيتبدّل الثيم في التطبيق كله مرة واحدة بدون hot reload.
abstract class AppColors {
  /// مُخطِر يتغيّر مع أي تبديل في الثيم/التباين — تستمع إليه كل الشاشات.
  static final ValueNotifier<int> uiNotifier = ValueNotifier<int>(0);

  static bool _isDark = false;
  static bool _highContrast = false;

  /// يُضبط من `MaterialApp.builder` حسب الثيم الفعّال (يدعم وضع النظام أيضًا).
  static bool get isDark => _isDark;
  static set isDark(bool value) {
    if (_isDark != value) {
      _isDark = value;
      uiNotifier.value++;
    }
  }

  /// وضع التباين العالي (إمكانية الوصول) — يُضبط من SettingsCubit.
  static bool get highContrast => _highContrast;
  static set highContrast(bool value) {
    if (_highContrast != value) {
      _highContrast = value;
      uiNotifier.value++;
    }
  }

  // ---- Brand (ثابتة) ----
  /// الأساسي — Indigo.
  static const Color primary = Color(0xff4F46E5);
  static const Color primaryDark = Color(0xff4338CA);

  /// الثانوي — Cyan.
  static const Color secondary = Color(0xff06B6D4);
  static const Color secondaryDark = Color(0xff0891B2);

  /// التمييز — Green.
  static const Color accent = Color(0xff22C55E);

  /// خلفية داكنة عميقة (Slate/Indigo).
  static const Color deepBg = Color(0xff0B1220);

  // ---- حالات ----
  static const Color success = Color(0xff22C55E);
  static const Color warning = Color(0xffF59E0B);
  static const Color error = Color(0xffEF4444);

  // ---- أسطح متبدّلة حسب الثيم (Dark-first) ----
  static Color get scaffoldBg =>
      isDark ? deepBg : const Color(0xffF5F7FF);
  static Color get card =>
      isDark ? const Color(0xff161E2E) : const Color(0xffFFFFFF);
  static Color get cardAlt =>
      isDark ? const Color(0xff1E2740) : const Color(0xffF1F4FF);
  static Color get mainText => highContrast
      ? (isDark ? const Color(0xffFFFFFF) : const Color(0xff000000))
      : (isDark ? const Color(0xffE8ECF5) : const Color(0xff0F172A));
  static Color get secondaryText => highContrast
      ? (isDark ? const Color(0xffCBD5E1) : const Color(0xff334155))
      : (isDark ? const Color(0xff94A3B8) : const Color(0xff5A6B86));
  static Color get border => highContrast
      ? (isDark ? const Color(0xff48597A) : const Color(0xff94A3B8))
      : (isDark ? const Color(0xff243047) : const Color(0xffE5E9F2));

  /// خلفيات ناعمة ملوّنة (للأيقونات/الشارات/البطاقات المميّزة).
  static Color get softPrimary =>
      isDark ? const Color(0x334F46E5) : const Color(0xffEAE9FD);
  static Color get softSecondary =>
      isDark ? const Color(0x3306B6D4) : const Color(0xffDFF6FB);
  static Color get softAccent =>
      isDark ? const Color(0x3322C55E) : const Color(0xffDDF6E6);

  // ---- Legacy aliases (تُستخدم في core widgets المشتركة — لا تحذفها) ----
  // أسماء قديمة (navy/orange) أُعيد توجيه قيمها لهوية VoiceBridge AI.
  static const Color navy = Color(0xff312E81); // indigo غامق (نص فوق الخلفيات)
  static const Color navy2 = Color(0xff3730A3);
  static const Color orange = primary; // لون CTA → الآن Indigo
  static const Color orange2 = secondary;
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
