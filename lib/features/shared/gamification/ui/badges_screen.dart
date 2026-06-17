import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../data/models/gamification_models.dart';
import '../logic/gamification_cubit.dart';

/// شاشة الأوسمة والمكافآت — مستوى/نقاط + شبكة الأوسمة (مكتسب/مقفل).
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Transform.flip(
            flipX: context.locale.languageCode == 'ar',
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18.w, color: AppColors.mainText),
          ),
        ),
        title: AppText(
          text: LocaleKeys.rewards.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<GamificationCubit, int>(
        builder: (context, _) {
          final cubit = context.read<GamificationCubit>();
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LevelCard(cubit: cubit),
                SizedBox(height: 20.h),
                AppText(
                  text: LocaleKeys.badges.tr(),
                  size: 16.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.mainText,
                ),
                SizedBox(height: 12.h),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.82,
                  children: cubit.badges.map((b) => _BadgeTile(badge: b)).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final GamificationCubit cubit;
  const _LevelCard({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
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
                width: 54.w,
                height: 54.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: AppText(
                  text: '${cubit.level}',
                  size: 22.sp,
                  family: FontFamily.tajawalBold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: '${LocaleKeys.levelN.tr()} ${cubit.level}',
                      size: 18.sp,
                      family: FontFamily.tajawalBold,
                      color: Colors.white,
                    ),
                    AppText(
                      text: '${cubit.xp}/${cubit.xpToNext} ${LocaleKeys.xp.tr()}',
                      size: 12.sp,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: Colors.white),
                  SizedBox(width: 4.w),
                  AppText(
                    text: '${cubit.streakDays}',
                    size: 18.sp,
                    family: FontFamily.tajawalBold,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 8.h,
            percent: cubit.levelProgress,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            progressColor: Colors.white,
            barRadius: Radius.circular(8.r),
            animation: true,
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final AppBadge badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final earned = badge.earned;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: earned ? badge.color.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: earned
                  ? badge.color.withValues(alpha: 0.16)
                  : AppColors.secondaryText.withValues(alpha: 0.12),
            ),
            child: Icon(
              earned ? badge.icon : Icons.lock_rounded,
              color: earned ? badge.color : AppColors.secondaryText,
              size: 26.w,
            ),
          ),
          SizedBox(height: 8.h),
          AppText(
            text: badge.labelKey.tr(),
            size: 10.sp,
            lines: 2,
            textAlign: TextAlign.center,
            family: FontFamily.tajawalMedium,
            color: earned ? AppColors.mainText : AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}
