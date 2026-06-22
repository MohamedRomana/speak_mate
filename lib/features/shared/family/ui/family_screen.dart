import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/di/dependancy_injection.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/flash_message.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../data/models/child_profile.dart';
import '../data/repos/family_repo.dart';
import '../logic/family_cubit.dart';
import 'add_child_sheet.dart';

/// شاشة "أطفالي" — تبديل/إضافة ملفات الأطفال (الباقة العائلية).
class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FamilyCubit(getIt<FamilyRepo>())..load(),
      child: const _FamilyView(),
    );
  }
}

class _FamilyView extends StatelessWidget {
  const _FamilyView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FamilyCubit>();
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
          text: LocaleKeys.familyTitle.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<FamilyCubit, int>(
        builder: (context, _) {
          if (cubit.phase == FamilyPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cubit.phase == FamilyPhase.error) {
            return Center(
              child: AppText(
                text: cubit.errorMsg ?? LocaleKeys.somethingWentWrong.tr(),
                size: 14.sp,
                color: AppColors.warning,
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 28.h),
            children: [
              ...cubit.children.map((c) => _ChildCard(
                    child: c,
                    active: cubit.activeId == c.id,
                    onTap: () => _switch(context, cubit, c),
                  )),
              SizedBox(height: 8.h),
              if (cubit.canAddMore)
                OutlinedButton.icon(
                  onPressed: () => _add(context, cubit),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.h),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  icon: Icon(Icons.add_rounded, size: 20.w, color: AppColors.primary),
                  label: AppText(
                    text: LocaleKeys.addChild.tr(),
                    size: 14.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.primary,
                  ),
                )
              else
                AppText(
                  text: LocaleKeys.maxChildrenReached.tr(),
                  size: 12.sp,
                  textAlign: TextAlign.center,
                  color: AppColors.secondaryText,
                  lines: 2,
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _switch(
      BuildContext context, FamilyCubit cubit, ChildProfile c) async {
    await cubit.switchActive(c);
    if (!context.mounted || cubit.activeId != c.id) return;
    showFlashMessage(
      message: LocaleKeys.switchedToChild.tr().replaceFirst('{}', c.name),
      type: FlashMessageType.success,
      context: context,
    );
  }

  Future<void> _add(BuildContext context, FamilyCubit cubit) async {
    final added = await showAddChildSheet(context, cubit);
    if (added == true && context.mounted) {
      showFlashMessage(
        message: LocaleKeys.childAdded.tr(),
        type: FlashMessageType.success,
        context: context,
      );
    }
  }
}

class _ChildCard extends StatelessWidget {
  final ChildProfile child;
  final bool active;
  final VoidCallback onTap;
  const _ChildCard({required this.child, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.06) : AppColors.card,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: active ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.softPrimary,
                shape: BoxShape.circle,
              ),
              child: Text(child.emoji, style: TextStyle(fontSize: 26.sp)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: AppText(
                          text: child.name,
                          size: 15.sp,
                          family: FontFamily.tajawalBold,
                          color: AppColors.mainText,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if (active)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: AppText(
                            text: LocaleKeys.activeChildLabel.tr(),
                            size: 10.sp,
                            family: FontFamily.tajawalBold,
                            color: AppColors.success,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  AppText(
                    text: '${child.age} • ${child.difficultyType.tr()}',
                    size: 11.sp,
                    color: AppColors.secondaryText,
                    lines: 1,
                  ),
                  SizedBox(height: 8.h),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    lineHeight: 6.h,
                    percent: (child.progress / 100).clamp(0, 1),
                    backgroundColor: AppColors.border,
                    progressColor: AppColors.primary,
                    barRadius: Radius.circular(6.r),
                    animation: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
