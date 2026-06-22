import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../appointments/ui/appointments_screen.dart';
import '../../billing/ui/subscription_screen.dart';
import 'my_plan_screen.dart';

/// كرت مدخل "خطّتي العلاجية" في لوحة المتدرّب.
class MyPlanCta extends StatelessWidget {
  const MyPlanCta({super.key});

  @override
  Widget build(BuildContext context) {
    return _Cta(
      icon: Icons.assignment_rounded,
      title: LocaleKeys.myPlan.tr(),
      subtitle: LocaleKeys.viewMyPlan.tr(),
      onTap: () => context.pushScreen(const MyPlanScreen()),
    );
  }
}

/// كرت مدخل قابل لإعادة الاستخدام (سهم اتجاهي + أيقونة).
class _Cta extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _Cta({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.softPrimary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: title,
                    size: 14.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                  ),
                  SizedBox(height: 3.h),
                  AppText(
                    text: subtitle,
                    size: 11.sp,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ),
            Transform.flip(
              flipX: context.locale.languageCode == 'ar',
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 14.w, color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

/// كرت مدخل "مواعيدي" في لوحة المتدرّب.
class AppointmentsCta extends StatelessWidget {
  const AppointmentsCta({super.key});

  @override
  Widget build(BuildContext context) {
    return _Cta(
      icon: Icons.event_available_rounded,
      title: LocaleKeys.myAppointments.tr(),
      subtitle: LocaleKeys.bookAppointment.tr(),
      onTap: () => context.pushScreen(const AppointmentsScreen()),
    );
  }
}

/// كرت مدخل "الاشتراك".
class SubscriptionCta extends StatelessWidget {
  const SubscriptionCta({super.key});

  @override
  Widget build(BuildContext context) {
    return _Cta(
      icon: Icons.workspace_premium_rounded,
      title: LocaleKeys.subscriptionTitle.tr(),
      subtitle: LocaleKeys.choosePlan.tr(),
      onTap: () => context.pushScreen(const SubscriptionScreen()),
    );
  }
}
