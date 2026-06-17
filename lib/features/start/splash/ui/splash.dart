import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/helper/theme_x.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../../core/routing/routes.dart';

/// شاشة البداية — أنميشن دماغ AI + موجة صوت ثم توجيه ذكي حسب حالة الكاش.
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
    _timer = Timer(const Duration(milliseconds: 2400), _decideNext);
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
      next = switch (CacheHelper.getUserType()) {
        UserTypes.therapist => Routes.therapistHome,
        UserTypes.clinic => Routes.clinicHome,
        UserTypes.adult => Routes.adultHome,
        _ => Routes.patientHome,
      };
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
              const _AiBrainLogo(),
              SizedBox(height: 28.h),
              FadeSlideIn(
                delay: const Duration(milliseconds: 500),
                child: Text(
                  'VoiceBridge AI',
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

/// شعار AI متحرّك: دماغ داخل دائرة متدرّجة نابضة + موجة صوت تحته.
class _AiBrainLogo extends StatefulWidget {
  const _AiBrainLogo();

  @override
  State<_AiBrainLogo> createState() => _AiBrainLogoState();
}

class _AiBrainLogoState extends State<_AiBrainLogo>
    with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _entry.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _pulse]),
      builder: (context, _) {
        final entry = Curves.easeOutBack.transform(_entry.value.clamp(0, 1));
        final t = _pulse.value;
        return Opacity(
          opacity: _entry.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.7 + 0.3 * entry,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 170.w,
                  height: 170.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // حلقات نابضة (موجات).
                      for (var i = 0; i < 2; i++)
                        Builder(builder: (_) {
                          final p = ((t + i * 0.5) % 1.0);
                          return Container(
                            width: (110 + p * 60).w,
                            height: (110 + p * 60).w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.secondary
                                    .withValues(alpha: (1 - p) * 0.5),
                                width: 2,
                              ),
                            ),
                          );
                        }),
                      // دائرة الدماغ المتدرّجة.
                      Container(
                        width: 110.w,
                        height: 110.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(Icons.psychology_rounded,
                            color: Colors.white, size: 60.w),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                // موجة صوت متحرّكة.
                SizedBox(
                  height: 30.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(9, (i) {
                      final phase = math.sin((t * 2 * math.pi) + i * 0.7);
                      final h = 6 + (phase.abs() * 22);
                      return Container(
                        width: 4.w,
                        height: h.h,
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        decoration: BoxDecoration(
                          color: i.isEven
                              ? AppColors.secondary
                              : AppColors.accent,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
