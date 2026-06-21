import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/di/dependancy_injection.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/flash_message.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/satha_field.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../data/models/therapy_plan.dart';
import '../data/repos/plans_repo.dart';
import '../logic/create_plan_cubit.dart';

/// شاشة إنشاء خطة مخصّصة (أخصائي). ترجع [TherapyPlan] المُنشأة عند الحفظ.
class CreatePlanScreen extends StatelessWidget {
  const CreatePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreatePlanCubit(getIt<PlansRepo>()),
      child: const _CreatePlanView(),
    );
  }
}

class _CreatePlanView extends StatelessWidget {
  const _CreatePlanView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreatePlanCubit>();
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
          text: LocaleKeys.newCustomPlan.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<CreatePlanCubit, int>(
        builder: (context, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SathaField(
                  label: LocaleKeys.planTitle.tr(),
                  hint: LocaleKeys.planTitle.tr(),
                  onChanged: cubit.setTitle,
                ),
                SizedBox(height: 14.h),
                SathaField(
                  label: LocaleKeys.planGoal.tr(),
                  hint: LocaleKeys.planGoal.tr(),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  onChanged: cubit.setGoal,
                ),
                SizedBox(height: 18.h),
                _label(LocaleKeys.targetSounds.tr()),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: CreatePlanCubit.soundPalette.map((s) {
                    final on = cubit.sounds.contains(s);
                    return GestureDetector(
                      onTap: () => cubit.toggleSound(s),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: on ? AppColors.primary : AppColors.card,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: on ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: AppText(
                          text: s,
                          size: 17.sp,
                          family: FontFamily.tajawalBold,
                          color: on ? Colors.white : AppColors.mainText,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 18.h),
                _Stepper(
                  label: LocaleKeys.durationWeeks.tr(),
                  value: cubit.durationWeeks,
                  unit: LocaleKeys.weeksUnit.tr(),
                  onMinus: () => cubit.setDuration(cubit.durationWeeks - 1),
                  onPlus: () => cubit.setDuration(cubit.durationWeeks + 1),
                ),
                SizedBox(height: 12.h),
                _Stepper(
                  label: LocaleKeys.sessionsPerWeek.tr(),
                  value: cubit.sessionsPerWeek,
                  unit: LocaleKeys.sessionsUnit.tr(),
                  onMinus: () => cubit.setSessions(cubit.sessionsPerWeek - 1),
                  onPlus: () => cubit.setSessions(cubit.sessionsPerWeek + 1),
                ),
                SizedBox(height: 18.h),
                _label(LocaleKeys.weeklyTargetsSelect.tr()),
                SizedBox(height: 10.h),
                for (var i = 0; i < CreatePlanCubit.presetTargets.length; i++)
                  _TargetToggle(
                    index: i,
                    selected: cubit.targetIdx.contains(i),
                    onTap: () => cubit.toggleTarget(i),
                  ),
                SizedBox(height: 24.h),
                PrimaryButton(
                  text: LocaleKeys.savePlan.tr(),
                  icon: Icons.save_rounded,
                  enabled: cubit.isValid,
                  loading: cubit.saving,
                  onPressed: () async {
                    final plan = await cubit.save();
                    if (!context.mounted) return;
                    if (plan != null) {
                      context.pop(plan);
                      showFlashMessage(
                        message: LocaleKeys.planCreated.tr(),
                        type: FlashMessageType.success,
                        context: context,
                      );
                    } else {
                      showFlashMessage(
                        message: cubit.errorMsg ?? LocaleKeys.somethingWentWrong.tr(),
                        type: FlashMessageType.error,
                        context: context,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) => AppText(
        text: text,
        size: 14.sp,
        family: FontFamily.tajawalBold,
        color: AppColors.mainText,
      );
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _Stepper({
    required this.label,
    required this.value,
    required this.unit,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: label,
              size: 13.sp,
              family: FontFamily.tajawalMedium,
              color: AppColors.mainText,
            ),
          ),
          _circleBtn(Icons.remove_rounded, onMinus),
          SizedBox(width: 14.w),
          AppText(
            text: '$value $unit',
            size: 14.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.primary,
          ),
          SizedBox(width: 14.w),
          _circleBtn(Icons.add_rounded, onPlus),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 30.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.softPrimary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18.w, color: AppColors.primary),
      ),
    );
  }
}

class _TargetToggle extends StatelessWidget {
  final int index;
  final bool selected;
  final VoidCallback onTap;
  const _TargetToggle({
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = CreatePlanCubit.presetTargets[index];
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.card,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(t.$2, style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 10.w),
            Expanded(
              child: AppText(
                text: '${t.$1} (${t.$3})',
                size: 13.sp,
                family: FontFamily.tajawalMedium,
                color: AppColors.mainText,
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: selected ? AppColors.primary : AppColors.secondaryText,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}
