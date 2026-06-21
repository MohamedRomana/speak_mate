import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../data/models/therapy_plan.dart';

/// كرت خطة علاجية — يُستخدم في ورقة الإسناد (قابل للاختيار) وفي شاشة خطتي.
class PlanCard extends StatelessWidget {
  final TherapyPlan plan;
  final bool selectable;
  final bool selected;
  final VoidCallback? onTap;
  const PlanCard({
    super.key,
    required this.plan,
    this.selectable = false,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selected ? AppColors.primary : AppColors.border;
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.card,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: accent, width: selected ? 1.6 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (selectable)
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? AppColors.primary : AppColors.secondaryText,
                    size: 20.w,
                  ),
                if (selectable) SizedBox(width: 8.w),
                Expanded(
                  child: AppText(
                    text: plan.title,
                    size: 15.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            AppText(
              text: plan.goal,
              size: 12.sp,
              lines: 2,
              overflow: TextOverflow.visible,
              color: AppColors.secondaryText,
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                _meta('⏱️', '${plan.durationWeeks} أسبوع'),
                _meta('📅', '${plan.sessionsPerWeek} جلسات/أسبوع'),
                if (plan.targetSounds.isNotEmpty)
                  _meta('🎯', plan.targetSounds.join(' · ')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(String emoji, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.softPrimary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 12.sp)),
          SizedBox(width: 5.w),
          AppText(
            text: text,
            size: 11.sp,
            family: FontFamily.tajawalMedium,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
