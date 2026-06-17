import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/helper/theme_x.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/user_role.dart';

/// شاشة اختيار الدور — متدرّب/ولي أمر أو أخصائي تخاطب.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _select(BuildContext context, UserRole role) {
    context.pushNamed(Routes.login, arguments: {'role': role});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedAuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 32.h),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 30.h),
                FadeSlideIn(
                  child: Text(
                    LocaleKeys.chooseRole.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontFamily: FontFamily.tajawalBold,
                      color: context.onBrand,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Text(
                    LocaleKeys.chooseRoleDesc.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.onBrandMuted,
                    ),
                  ),
                ),
                SizedBox(height: 28.h),
                _RoleCard(
                  icon: Icons.child_care_rounded,
                  color: AppColors.primary,
                  title: LocaleKeys.patientRole.tr(),
                  desc: LocaleKeys.patientRoleDesc.tr(),
                  delay: 220,
                  onTap: () => _select(context, UserRole.patient),
                ),
                SizedBox(height: 14.h),
                _RoleCard(
                  icon: Icons.elderly_rounded,
                  color: AppColors.secondary,
                  title: LocaleKeys.adultRole.tr(),
                  desc: LocaleKeys.adultRoleDesc.tr(),
                  delay: 300,
                  onTap: () => _select(context, UserRole.adult),
                ),
                SizedBox(height: 14.h),
                _RoleCard(
                  icon: Icons.medical_services_rounded,
                  color: AppColors.accent,
                  title: LocaleKeys.therapistRole.tr(),
                  desc: LocaleKeys.therapistRoleDesc.tr(),
                  delay: 380,
                  onTap: () => _select(context, UserRole.therapist),
                ),
                SizedBox(height: 14.h),
                _RoleCard(
                  icon: Icons.local_hospital_rounded,
                  color: AppColors.warning,
                  title: LocaleKeys.clinicRole.tr(),
                  desc: LocaleKeys.clinicRoleDesc.tr(),
                  delay: 460,
                  onTap: () => _select(context, UserRole.clinic),
                ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final int delay;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: Duration(milliseconds: delay),
      from: SlideFrom.bottom,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(22.r),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: context.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 30.w),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontFamily: FontFamily.tajawalBold,
                        color: context.onBrand,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.4,
                        color: context.onBrandMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.flip(
                flipX: context.locale.languageCode == 'ar',
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.w,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
