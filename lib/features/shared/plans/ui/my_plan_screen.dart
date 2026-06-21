import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/di/dependancy_injection.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../data/models/therapy_plan.dart';
import '../data/repos/plans_repo.dart';
import '../logic/my_plan_cubit.dart';
import 'widgets/plan_card.dart';

/// شاشة "خطّتي العلاجية" للمتدرّب — الخطة النشطة + تقدّمها وأهدافها الأسبوعية.
class MyPlanScreen extends StatelessWidget {
  const MyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyPlanCubit(getIt<PlansRepo>())..load(),
      child: const _MyPlanView(),
    );
  }
}

class _MyPlanView extends StatelessWidget {
  const _MyPlanView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyPlanCubit>();
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
          text: LocaleKeys.myPlan.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<MyPlanCubit, int>(
        builder: (context, _) {
          switch (cubit.phase) {
            case MyPlanPhase.loading:
              return const Center(child: CircularProgressIndicator());
            case MyPlanPhase.empty:
              return _Empty();
            case MyPlanPhase.error:
              return Center(
                child: AppText(
                  text: cubit.errorMsg ?? LocaleKeys.somethingWentWrong.tr(),
                  size: 14.sp,
                  color: AppColors.warning,
                ),
              );
            case MyPlanPhase.ready:
              return _PlanBody(plan: cubit.plan!);
          }
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, size: 56.w, color: AppColors.secondaryText),
          SizedBox(height: 12.h),
          AppText(
            text: LocaleKeys.noPlanYet.tr(),
            size: 14.sp,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

class _PlanBody extends StatelessWidget {
  final TherapyPlan plan;
  const _PlanBody({required this.plan});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // بطاقة التقدّم.
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 38.r,
                  lineWidth: 7.w,
                  percent: (plan.progress / 100).clamp(0, 1),
                  animation: true,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: Colors.white24,
                  progressColor: Colors.white,
                  center: AppText(
                    text: '${plan.progress}%',
                    size: 16.sp,
                    family: FontFamily.tajawalBold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: plan.title,
                        size: 16.sp,
                        family: FontFamily.tajawalBold,
                        color: Colors.white,
                        lines: 2,
                      ),
                      SizedBox(height: 6.h),
                      AppText(
                        text: LocaleKeys.planProgress.tr(),
                        size: 12.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          PlanCard(plan: plan),
          if (plan.targetSounds.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _Section(
              title: LocaleKeys.targetSounds.tr(),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: plan.targetSounds
                    .map((s) => Container(
                          width: 40.w,
                          height: 40.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.softPrimary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: AppText(
                            text: s,
                            size: 18.sp,
                            family: FontFamily.tajawalBold,
                            color: AppColors.primary,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
          if (plan.targets.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _Section(
              title: LocaleKeys.weeklyTargets.tr(),
              child: Column(
                children: [
                  for (final t in plan.targets)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _TargetRow(target: t),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: title,
            size: 14.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.mainText,
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final PlanTarget target;
  const _TargetRow({required this.target});

  @override
  Widget build(BuildContext context) {
    final done = target.ratio >= 1;
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? AppColors.softAccent : AppColors.softPrimary,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(target.emoji, style: TextStyle(fontSize: 16.sp)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: target.titleKey,
                size: 13.sp,
                family: FontFamily.tajawalMedium,
                color: AppColors.mainText,
              ),
              SizedBox(height: 5.h),
              LinearPercentIndicator(
                padding: EdgeInsets.zero,
                lineHeight: 6.h,
                percent: target.ratio.toDouble(),
                backgroundColor: AppColors.border,
                progressColor: done ? AppColors.accent : AppColors.primary,
                barRadius: Radius.circular(6.r),
                animation: true,
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        AppText(
          text: '${target.doneCount}/${target.targetCount}',
          size: 11.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.secondaryText,
        ),
      ],
    );
  }
}
