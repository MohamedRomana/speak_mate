import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/gradients.dart';

/// اختصارات للوصول لحالة الثيم (دارك/لايت) وألوان الـ brand المتوافقة معه.
/// تُستخدم في الشاشات ذات الخلفية المميّزة (Splash / Auth / Onboarding ...).
extension ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// تدرّج خلفية الـ brand حسب الثيم: داكن navy / فاتح ناعم.
  Gradient get brandGradient => isDark ? AppGradients.deep : AppGradients.light;

  /// لون النص/الأيقونات فوق خلفية الـ brand (أبيض في الداكن، navy في الفاتح).
  Color get onBrand => isDark ? Colors.white : AppColors.navy;

  /// لون النص الثانوي فوق خلفية الـ brand.
  Color get onBrandMuted => isDark
      ? Colors.white.withValues(alpha: 0.75)
      : AppColors.secondaryText;
}
