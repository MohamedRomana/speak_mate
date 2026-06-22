import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/satha_field.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../logic/family_cubit.dart';

/// ورقة سفلية لإضافة طفل جديد. ترجع true عند الإضافة.
Future<bool?> showAddChildSheet(BuildContext context, FamilyCubit cubit) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.scaffoldBg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const _AddChildSheet(),
    ),
  );
}

class _AddChildSheet extends StatefulWidget {
  const _AddChildSheet();

  @override
  State<_AddChildSheet> createState() => _AddChildSheetState();
}

class _AddChildSheetState extends State<_AddChildSheet> {
  static const _emojis = ['👦', '👧', '🧒', '👶', '🐱', '🐶', '🦊', '🐼'];

  final _name = TextEditingController();
  int _age = 6;
  String _difficulty = AppConstants.difficultyTypes.first;
  String _emoji = _emojis.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty;

  Future<void> _save() async {
    final cubit = context.read<FamilyCubit>();
    final ok = await cubit.addChild(
      name: _name.text.trim(),
      age: _age,
      difficultyType: _difficulty,
      emoji: _emoji,
    );
    if (!mounted) return;
    Navigator.of(context).pop(ok);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<FamilyCubit>();
    return Padding(
      padding: EdgeInsets.only(
        left: 18.w,
        right: 18.w,
        top: 14.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18.h,
      ),
      child: SingleChildScrollView(
        child: Column(
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
              text: LocaleKeys.addChild.tr(),
              size: 16.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.mainText,
            ),
            SizedBox(height: 16.h),
            SathaField(
              controller: _name,
              hint: LocaleKeys.childName.tr(),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 14.h),
            _label(LocaleKeys.chooseAvatar.tr()),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _emojis.map((e) {
                final on = _emoji == e;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? AppColors.primary.withValues(alpha: 0.12) : AppColors.card,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: on ? AppColors.primary : AppColors.border,
                        width: on ? 1.6 : 1,
                      ),
                    ),
                    child: Text(e, style: TextStyle(fontSize: 22.sp)),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 14.h),
            _label(LocaleKeys.age.tr()),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppText(
                      text: '$_age',
                      size: 15.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.primary,
                    ),
                  ),
                  _circle(Icons.remove_rounded,
                      () => setState(() => _age = (_age - 1).clamp(2, 17))),
                  SizedBox(width: 14.w),
                  _circle(Icons.add_rounded,
                      () => setState(() => _age = (_age + 1).clamp(2, 17))),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _label(LocaleKeys.difficultyType.tr()),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: AppConstants.difficultyTypes.map((d) {
                final on = _difficulty == d;
                return GestureDetector(
                  onTap: () => setState(() => _difficulty = d),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                    decoration: BoxDecoration(
                      color: on ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: on ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: AppText(
                      text: d.tr(),
                      size: 12.sp,
                      family: FontFamily.tajawalMedium,
                      color: on ? Colors.white : AppColors.mainText,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 22.h),
            PrimaryButton(
              text: LocaleKeys.addChild.tr(),
              icon: Icons.person_add_alt_1_rounded,
              enabled: _valid,
              loading: cubit.busy,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => AppText(
        text: text,
        size: 13.sp,
        family: FontFamily.tajawalBold,
        color: AppColors.mainText,
      );

  Widget _circle(IconData icon, VoidCallback onTap) => GestureDetector(
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
