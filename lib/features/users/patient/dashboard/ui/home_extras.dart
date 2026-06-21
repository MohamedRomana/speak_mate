import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/di/dependancy_injection.dart';
import '../../../../../core/helper/extentions.dart';
import '../../../../../core/services/weak_sounds_tracker.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../child/ai_speak/logic/ai_speak_cubit.dart';
import '../../../../child/ai_speak/ui/ai_speak_screen.dart';
import '../../../../shared/gamification/logic/gamification_cubit.dart';
import '../../../../shared/gamification/ui/badges_screen.dart';

/// كرت المستوى/النقاط/السلسلة — يفتح شاشة الأوسمة.
class GamificationCard extends StatelessWidget {
  const GamificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamificationCubit, int>(
      builder: (context, _) {
        final g = context.read<GamificationCubit>();
        return InkWell(
          borderRadius: BorderRadius.circular(22.r),
          onTap: () => context.pushScreen(
            BlocProvider.value(value: g, child: const BadgesScreen()),
          ),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: AppText(
                        text: '${g.level}',
                        size: 20.sp,
                        family: FontFamily.tajawalBold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: '${LocaleKeys.levelN.tr()} ${g.level}',
                            size: 16.sp,
                            family: FontFamily.tajawalBold,
                            color: Colors.white,
                          ),
                          AppText(
                            text: '${g.xp}/${g.xpToNext} ${LocaleKeys.xp.tr()}',
                            size: 11.sp,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.local_fire_department_rounded,
                        color: Colors.white),
                    SizedBox(width: 4.w),
                    AppText(
                      text: '${g.streakDays}',
                      size: 16.sp,
                      family: FontFamily.tajawalBold,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.emoji_events_rounded,
                        color: Colors.white.withValues(alpha: 0.9), size: 20.w),
                  ],
                ),
                SizedBox(height: 12.h),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 7.h,
                  percent: g.levelProgress,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  progressColor: Colors.white,
                  barRadius: Radius.circular(8.r),
                  animation: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// زر "تحدّث مع AI" البارز.
class AiSpeakCta extends StatelessWidget {
  const AiSpeakCta({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () {
        final g = context.read<GamificationCubit>();
        context.pushScreen(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: g),
              BlocProvider(create: (_) => AiSpeakCubit()),
            ],
            child: const AiSpeakScreen(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary]),
              ),
              child: Icon(Icons.mic_rounded, color: Colors.white, size: 26.w),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: LocaleKeys.aiSpeak.tr(),
                    size: 16.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                  ),
                  SizedBox(height: 2.h),
                  AppText(
                    text: LocaleKeys.aiSpeakDesc.tr(),
                    size: 11.sp,
                    lines: 2,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16.w, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

/// قسم الأهداف اليومية.
class DailyGoalsSection extends StatelessWidget {
  const DailyGoalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamificationCubit, int>(
      builder: (context, _) {
        final goals = context.read<GamificationCubit>().goals;
        if (goals.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_rounded, size: 20.w, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  AppText(
                    text: LocaleKeys.dailyGoals.tr(),
                    size: 15.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                  ),
                ],
              ),
              for (var i = 0; i < goals.length; i++)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Row(
                    children: [
                      Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: BoxDecoration(
                          color: goals[i].done
                              ? AppColors.softAccent
                              : AppColors.softPrimary,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          goals[i].done ? Icons.check_rounded : goals[i].icon,
                          size: 18.w,
                          color: goals[i].done
                              ? AppColors.accent
                              : AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: goals[i].labelKey.tr(),
                              size: 13.sp,
                              family: FontFamily.tajawalMedium,
                              color: AppColors.mainText,
                            ),
                            SizedBox(height: 5.h),
                            LinearPercentIndicator(
                              padding: EdgeInsets.zero,
                              lineHeight: 6.h,
                              percent: goals[i].ratio.toDouble(),
                              backgroundColor: AppColors.border,
                              progressColor: goals[i].done
                                  ? AppColors.accent
                                  : AppColors.primary,
                              barRadius: Radius.circular(6.r),
                              animation: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      AppText(
                        text: '${goals[i].progress}/${goals[i].target}',
                        size: 11.sp,
                        family: FontFamily.tajawalBold,
                        color: AppColors.secondaryText,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// خريطة الأصوات الضعيفة — أكثر الفونيمات احتياجًا للتدريب عبر كل التمارين،
/// تقرأ من `WeakSoundsTracker` الذي تغذّيه كيوبتس التمارين/تحدّث مع AI/الكبار.
class WeakSoundsHeatmap extends StatelessWidget {
  const WeakSoundsHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = getIt<WeakSoundsTracker>();
    final top = tracker.top(8);
    if (top.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.graphic_eq_rounded, size: 20.w, color: AppColors.secondary),
              SizedBox(width: 8.w),
              AppText(
                text: LocaleKeys.weakSounds.tr(),
                size: 15.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
              ),
            ],
          ),
          SizedBox(height: 4.h),
          AppText(
            text: LocaleKeys.weakSoundsHint.tr(),
            size: 11.sp,
            lines: 2,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: top.map(_chip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chip(WeakSound s) {
    // كلما زادت نسبة الخطأ زاد احمرار الرقاقة (تأثير حراري).
    final t = s.errorRate.clamp(0.0, 1.0);
    final color = Color.lerp(AppColors.warning, AppColors.error, t)!;
    final glyph = s.label.split(' ').first; // الحرف العربي فقط
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12 + t * 0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: glyph,
            size: 16.sp,
            family: FontFamily.tajawalBold,
            color: color,
          ),
          SizedBox(width: 6.w),
          AppText(
            text: '${(s.errorRate * 100).round()}%',
            size: 11.sp,
            family: FontFamily.tajawalMedium,
            color: color,
          ),
        ],
      ),
    );
  }
}
