import 'package:flutter/material.dart';
import 'colors.dart';

/// تدرّجات هوية SpeakMate — تُستخدم في الخلفيات والأزرار والشعار.
abstract class AppGradients {
  /// تدرّج الـ brand الأساسي (أزرق → لافندر) للأزرار والعناصر المميّزة.
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.secondary],
  );

  /// تدرّج أزرق نقي للـ CTA (اسم legacy `orange` محفوظ لتوافق الـ widgets).
  static const LinearGradient orange = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  /// تدرّج بنفسجي ناعم.
  static const LinearGradient lavender = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondary, AppColors.secondaryDark],
  );

  /// تدرّج نعناعي.
  static const LinearGradient mint = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent, Color(0xff2AA98C)],
  );

  /// تدرّج داكن عميق للخلفيات (Splash / Auth في الوضع الداكن).
  static const LinearGradient deep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.deepBg, Color(0xff142544), Color(0xff1B2E52)],
  );

  /// تدرّج فاتح ناعم لخلفيات الشاشات في الوضع الفاتح.
  static const LinearGradient light = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xffFFFFFF), Color(0xffF5F8FF), Color(0xffF1ECFC)],
  );
}

/// ظلال موحّدة للبطاقات والأزرار.
abstract class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.32),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  /// alias قديم.
  static List<BoxShadow> orangeGlow = glow;
}
