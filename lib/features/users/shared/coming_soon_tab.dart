import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../gen/fonts.gen.dart';
import '../../../generated/locale_keys.g.dart';

/// تبويب مؤقت "قريبًا" — يُستخدم للميزات التي ستُبنى في مراحل لاحقة.
class ComingSoonTab extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const ComingSoonTab({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeSlideIn(
                  from: SlideFrom.none,
                  beginScale: 0.8,
                  child: Container(
                    width: 110.w,
                    height: 110.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.12),
                    ),
                    child: Icon(icon, size: 52.w, color: color),
                  ),
                ),
                SizedBox(height: 24.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: AppText(
                    text: title,
                    size: 20.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                  ),
                ),
                SizedBox(height: 8.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 220),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softPrimary,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: AppText(
                      text: '🚧 ${LocaleKeys.comingSoon.tr()}',
                      size: 13.sp,
                      color: AppColors.primary,
                      family: FontFamily.tajawalMedium,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 320),
                  child: AppText(
                    text: LocaleKeys.comingSoonDesc.tr(),
                    size: 13.sp,
                    lines: 3,
                    textAlign: TextAlign.center,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
