import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// منتقيات تاريخ/وقت موحّدة بألوان التطبيق — تُستخدم في كل التطبيق
/// بدل `showDatePicker`/`showTimePicker` الافتراضية.
class AppPicker {
  AppPicker._();

  /// ثيم موحّد للـ date/time picker بألوان التطبيق.
  static Widget _theme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary, // الهيدر والعنصر المختار
          onPrimary: Colors.white, // نص العنصر المختار
          onSurface: AppColors.primary, // باقي النصوص
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          hourMinuteColor: AppColors.primary.withAlpha(20),
          hourMinuteTextColor: AppColors.primary,
          dialHandColor: AppColors.primary,
          dialBackgroundColor: AppColors.primary.withAlpha(20),
          entryModeIconColor: AppColors.primary,
        ),
      ),
      child: child!,
    );
  }

  /// منتقي تاريخ بستايل التطبيق.
  static Future<DateTime?> date(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? now,
      lastDate: lastDate ?? DateTime(now.year + 3),
      builder: _theme,
    );
  }

  /// منتقي وقت بستايل التطبيق.
  static Future<TimeOfDay?> time(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: _theme,
    );
  }
}
