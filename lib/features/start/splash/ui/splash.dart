import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/helper/theme_x.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../core/routing/routes.dart';

/// شاشة البداية — شعار متحرّك ثم توجيه ذكي حسب حالة الكاش.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), _decideNext);
  }

  void _decideNext() {
    if (!mounted) return;
    final String next;
    if (CacheHelper.getLang().isEmpty) {
      next = Routes.language;
    } else if (!CacheHelper.getShowIntro()) {
      next = Routes.onBoarding;
    } else if (CacheHelper.getUserId().isEmpty) {
      next = Routes.roleSelection;
    } else {
      next = CacheHelper.getUserType() == UserTypes.therapist
          ? Routes.therapistHome
          : Routes.patientHome;
    }
    context.pushReplacementNamed(next);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedAuthBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AnimatedAppLogo(size: 130),
              SizedBox(height: 24.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 500),
                child: Text(
                  LocaleKeys.appName.tr(),
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontFamily: FontFamily.tajawalBold,
                    color: context.onBrand,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 750),
                child: Text(
                  LocaleKeys.appTagline.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.onBrandMuted,
                    fontFamily: FontFamily.tajawalRegular,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 1000),
                child: SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: context.onBrand.withValues(alpha: 0.7),
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
