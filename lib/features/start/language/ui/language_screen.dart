import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/helper/theme_x.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/auth_background.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';

/// شاشة اختيار اللغة — تظهر عند أول تشغيل، وقابلة لإعادة الاستخدام من الإعدادات.
class LanguageScreen extends StatefulWidget {
  /// لو true (أول تشغيل) تكمل لشاشة الـ onboarding، وإلا ترجع للخلف.
  final bool firstLaunch;
  const LanguageScreen({super.key, this.firstLaunch = true});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selected =
      context.locale.languageCode.isEmpty ? 'ar' : context.locale.languageCode;

  Future<void> _confirm() async {
    final locale = Locale(_selected);
    await CacheHelper.setLang(_selected);
    if (!mounted) return;
    await context.setLocale(locale);
    if (!mounted) return;
    if (widget.firstLaunch) {
      context.pushReplacementNamed(Routes.onBoarding);
    } else {
      context.pop();
    }
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
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32.h),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: 30.h),
                FadeSlideIn(
                  child: Icon(
                    Icons.translate_rounded,
                    size: 56.w,
                    color: context.onBrand,
                  ),
                ),
                SizedBox(height: 20.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    LocaleKeys.chooseLanguage.tr(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontFamily: FontFamily.tajawalBold,
                      color: context.onBrand,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    LocaleKeys.chooseLanguageDesc.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.onBrandMuted,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                _LangCard(
                  flag: '🇸🇦',
                  title: LocaleKeys.arabic.tr(),
                  subtitle: 'العربية',
                  selected: _selected == 'ar',
                  onTap: () => setState(() => _selected = 'ar'),
                  delay: 300,
                ),
                SizedBox(height: 16.h),
                _LangCard(
                  flag: '🇬🇧',
                  title: LocaleKeys.english.tr(),
                  subtitle: 'English',
                  selected: _selected == 'en',
                  onTap: () => setState(() => _selected = 'en'),
                  delay: 400,
                ),
                const Spacer(),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 500),
                  child: PrimaryButton(
                    text: LocaleKeys.continueWord.tr(),
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _confirm,
                  ),
                ),
                      SizedBox(height: 10.h),
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

class _LangCard extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final int delay;

  const _LangCard({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.delay,
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
        borderRadius: BorderRadius.circular(18.r),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : (context.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: TextStyle(fontSize: 28.sp)),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: FontFamily.tajawalBold,
                        color: context.onBrand,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.onBrandMuted,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 24.w,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
