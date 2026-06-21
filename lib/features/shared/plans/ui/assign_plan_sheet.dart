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
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../data/models/therapy_plan.dart';
import '../data/repos/plans_repo.dart';
import '../logic/assign_plan_cubit.dart';
import 'create_plan_screen.dart';
import 'widgets/plan_card.dart';

/// يعرض ورقة سفلية لإسناد خطة علاجية لمريض. يرجّع true لو تمّ الإسناد.
Future<bool?> showAssignPlanSheet(BuildContext context, String patientId) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.scaffoldBg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => AssignPlanCubit(getIt<PlansRepo>(), patientId: patientId)..load(),
      child: const _AssignPlanSheet(),
    ),
  );
}

class _AssignPlanSheet extends StatelessWidget {
  const _AssignPlanSheet();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AssignPlanCubit>();
    return Padding(
      padding: EdgeInsets.only(
        left: 18.w,
        right: 18.w,
        top: 14.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18.h,
      ),
      child: BlocBuilder<AssignPlanCubit, int>(
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              AppText(
                text: LocaleKeys.assignPlan.tr(),
                size: 17.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
              ),
              SizedBox(height: 4.h),
              AppText(
                text: LocaleKeys.choosePlanHint.tr(),
                size: 12.sp,
                color: AppColors.secondaryText,
              ),
              SizedBox(height: 12.h),
              if (cubit.phase != AssignPhase.loading &&
                  cubit.phase != AssignPhase.error)
                OutlinedButton.icon(
                  onPressed: () async {
                    final created =
                        await context.pushScreen<TherapyPlan?>(const CreatePlanScreen());
                    if (created != null) cubit.addTemplate(created);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 44.h),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  icon: Icon(Icons.add_rounded, size: 18.w, color: AppColors.primary),
                  label: AppText(
                    text: LocaleKeys.newCustomPlan.tr(),
                    size: 13.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.primary,
                  ),
                ),
              SizedBox(height: 14.h),
              if (cubit.phase == AssignPhase.loading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (cubit.phase == AssignPhase.error)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.h),
                  child: AppText(
                    text: cubit.errorMsg ?? LocaleKeys.somethingWentWrong.tr(),
                    size: 13.sp,
                    textAlign: TextAlign.center,
                    color: AppColors.warning,
                  ),
                )
              else ...[
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final p in cubit.templates) ...[
                          PlanCard(
                            plan: p,
                            selectable: true,
                            selected: cubit.selectedId == p.id,
                            onTap: () => cubit.select(p.id),
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                PrimaryButton(
                  text: LocaleKeys.assignPlan.tr(),
                  icon: Icons.assignment_turned_in_rounded,
                  loading: cubit.phase == AssignPhase.assigning,
                  onPressed: () async {
                    final ok = await cubit.assign();
                    if (!context.mounted) return;
                    if (ok) {
                      Navigator.of(context).pop(true);
                      showFlashMessage(
                        message: LocaleKeys.planAssigned.tr(),
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
            ],
          );
        },
      ),
    );
  }
}
