import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../../gen/fonts.gen.dart';

/// ثيمات VoiceBridge AI — Dark (افتراضي) و Light بهوية Indigo/Cyan،
/// مع حفاظ على التباين والقراءة في الوضعين.
abstract class AppTheme {
  static const _fontFamily = FontFamily.tajawalRegular;

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      error: AppColors.error,
      surface: const Color(0xffFFFFFF),
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: const Color(0xffF5F7FF),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      error: AppColors.error,
      surface: const Color(0xff161E2E),
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.deepBg,
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      fontFamily: _fontFamily,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
