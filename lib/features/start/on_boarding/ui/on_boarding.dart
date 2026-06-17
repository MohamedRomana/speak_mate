import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/helper/theme_x.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import 'widgets/onboarding_page.dart';

/// onboarding carousel — 3 صفحات ثنائية اللغة بحركات ناعمة.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  List<OnboardingData> get _pages => [
        OnboardingData(
          icon: Icons.child_care_rounded,
          color: AppColors.primary,
          title: LocaleKeys.onboardTitle1.tr(),
          desc: LocaleKeys.onboardDesc1.tr(),
        ),
        OnboardingData(
          icon: Icons.elderly_rounded,
          color: AppColors.secondary,
          title: LocaleKeys.onboardTitle2.tr(),
          desc: LocaleKeys.onboardDesc2.tr(),
        ),
        OnboardingData(
          icon: Icons.psychology_rounded,
          color: AppColors.accent,
          title: LocaleKeys.onboardTitle3.tr(),
          desc: LocaleKeys.onboardDesc3.tr(),
        ),
      ];

  bool get _isLast => _index == _pages.length - 1;

  void _finish() {
    CacheHelper.setShowIntro(true);
    context.pushReplacementNamed(Routes.roleSelection);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    return Scaffold(
      body: AnimatedAuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              // زر التخطّي
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      LocaleKeys.skip.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.onBrandMuted,
                        fontFamily: FontFamily.tajawalMedium,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => OnboardingPage(data: pages[i]),
                ),
              ),
              SizedBox(height: 8.h),
              DotsIndicator(
                dotsCount: pages.length,
                position: _index.toDouble(),
                decorator: DotsDecorator(
                  activeColor: AppColors.primary,
                  color: context.onBrandMuted.withValues(alpha: 0.4),
                  size: Size(8.w, 8.w),
                  activeSize: Size(24.w, 8.w),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: PrimaryButton(
                  text: _isLast
                      ? LocaleKeys.getStarted.tr()
                      : LocaleKeys.next.tr(),
                  icon: _isLast
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  onPressed: _next,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
