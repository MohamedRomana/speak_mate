import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/di/dependancy_injection.dart';
import '../../../../../core/logic/action_state.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../core/widgets/custom_shimmer.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../data/models/exercise_models.dart';
import '../logic/exercise_player_cubit.dart';
import '../logic/exercises_cubit.dart';
import 'category_visuals.dart';
import 'exercise_player_screen.dart';

/// تبويب التمارين — فئات تفاعلية مع نسبة تقدّم.
class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: BlocBuilder<ExercisesCubit, ActionState>(
          builder: (context, state) {
            final cubit = context.read<ExercisesCubit>();
            if (state is ActionLoading && cubit.categories.isEmpty) {
              return const _Shimmer();
            }
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: LocaleKeys.navExercises.tr(),
                    size: 22.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                  ),
                  SizedBox(height: 16.h),
                  AnimationLimiter(
                    child: Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 375),
                        childAnimationBuilder: (w) => SlideAnimation(
                          verticalOffset: 40,
                          child: FadeInAnimation(child: w),
                        ),
                        children: cubit.categories
                            .map((c) => _CategoryCard(info: c))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ExerciseCategoryInfo info;
  const _CategoryCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final cat = info.category;
    final color = cat.color;
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) =>
                    ExercisePlayerCubit(getIt(), category: cat)..load(),
                child: const ExercisePlayerScreen(),
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 54.w,
                    height: 54.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(cat.icon, color: Colors.white, size: 28.w),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: cat.titleKey.tr(),
                          size: 16.sp,
                          family: FontFamily.tajawalBold,
                          color: AppColors.mainText,
                        ),
                        SizedBox(height: 3.h),
                        AppText(
                          text: cat.descKey.tr(),
                          size: 11.sp,
                          lines: 2,
                          color: AppColors.secondaryText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      lineHeight: 8.h,
                      percent: info.progress.clamp(0, 1),
                      backgroundColor: AppColors.border,
                      progressColor: color,
                      barRadius: Radius.circular(8.r),
                      animation: true,
                      animationDuration: 800,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  AppText(
                    text: '${info.completed}/${info.total}',
                    size: 12.sp,
                    family: FontFamily.tajawalBold,
                    color: color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: CustomShimmer(
              child: Container(
                height: 120.h,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
