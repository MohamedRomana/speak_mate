import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../gen/fonts.gen.dart';

/// خطوط VoiceBridge AI — **Cairo** أساسي (يدعم العربية والإنجليزية)، مع Tajawal
/// المضمّن كـ fallback أوفلاين. يُحوّل أسماء عائلات Tajawal القديمة إلى أوزان Cairo
/// حتى يتبدّل الخط في كل التطبيق دون تعديل مئات مواضع الاستدعاء.
abstract class AppFonts {
  /// وزن الخط المشتق من اسم العائلة الممرّر (للتوافق مع الكود القائم).
  static FontWeight weightFor(String? family, [FontWeight? explicit]) {
    if (explicit != null) return explicit;
    if (family == FontFamily.tajawalBold) return FontWeight.w700;
    if (family == FontFamily.tajawalMedium) return FontWeight.w500;
    return FontWeight.w400;
  }

  static const List<String> _fallback = [
    FontFamily.tajawalRegular,
    FontFamily.tajawalBold,
  ];

  /// نمط نصّ بخط Cairo مع الـ fallback المضمّن.
  static TextStyle cairo({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    Color? decorationColor,
    double? height,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationColor: decorationColor,
      height: height,
    ).copyWith(fontFamilyFallback: _fallback);
  }
}
