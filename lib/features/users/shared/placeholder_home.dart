import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/cache/cache_helper.dart';
import '../../../core/constants/colors.dart';
import '../../../core/helper/extentions.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/lang_toggle.dart';
import '../../../core/widgets/theme_toggle.dart';
import '../../../gen/fonts.gen.dart';
import '../../../generated/locale_keys.g.dart';
import '../../../core/routing/routes.dart';

/// شاشة رئيسية مؤقتة — تُستبدل بالـ Layout الفعلي في المراحل القادمة.
/// تُرحّب بالمستخدم وتتيح تبديل الثيم/اللغة وتسجيل الخروج.
class PlaceholderHome extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String roleTitle;

  const PlaceholderHome({
    super.key,
    required this.icon,
    required this.color,
    required this.roleTitle,
  });

  void _logout(BuildContext context) {
    CacheHelper.setUserId('');
    CacheHelper.setUserType('');
    context.pushNamedAndRemoveUntil(
      Routes.roleSelection,
      predicate: (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = CacheHelper.getUserName();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          const LangToggle(),
          SizedBox(width: 8.w),
          const ThemeToggle(),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: LocaleKeys.logout.tr(),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeSlideIn(
                from: SlideFrom.none,
                beginScale: 0.8,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 56.w, color: Colors.white),
                ),
              ),
              SizedBox(height: 28.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  '${LocaleKeys.welcomeBack.tr()}، $name 👋',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontFamily: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 250),
                child: Text(
                  roleTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 350),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softPrimary,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    '🚧 ${LocaleKeys.loading.tr()}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primary,
                      fontFamily: FontFamily.tajawalMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
