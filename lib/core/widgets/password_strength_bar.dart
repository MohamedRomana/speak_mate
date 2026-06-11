import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../generated/locale_keys.g.dart';
import '../constants/colors.dart';
import '../helper/validators.dart';

/// مؤشّر قوة كلمة المرور المتحرّك (ضعيفة / متوسطة / قوية).
class PasswordStrengthBar extends StatelessWidget {
  final String password;
  const PasswordStrengthBar({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final strength = password.passwordStrength;

    final config = switch (strength) {
      PasswordStrength.weak => (1, AppColors.error, LocaleKeys.passwordWeak),
      PasswordStrength.medium => (2, AppColors.warning, LocaleKeys.passwordMedium),
      PasswordStrength.strong => (3, AppColors.success, LocaleKeys.passwordStrong),
    };
    final filled = config.$1;
    final color = config.$2;

    return Padding(
      padding: EdgeInsetsDirectional.only(top: 8.h, start: 4.w, end: 4.w),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300 + (i * 100)),
                curve: Curves.easeOut,
                height: 5.h,
                margin: EdgeInsetsDirectional.only(end: i < 2 ? 6.w : 0),
                decoration: BoxDecoration(
                  color: i < filled ? color : AppColors.border,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          SizedBox(width: 10.w),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              config.$3.tr(),
              key: ValueKey(filled),
              style: TextStyle(
                fontSize: 11.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
