import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../core/widgets/primary_button.dart';
import '../../../../../../core/widgets/satha_field.dart';
import '../../../../../../gen/fonts.gen.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../logic/aac_cubit.dart';

const _emojiPalette = [
  '😀', '😍', '🤔', '😴', '👍', '👎', '🙌', '✋',
  '🍕', '🍔', '🍪', '🍓', '🐶', '🐱', '🦋', '🌟',
  '⚽', '🎈', '🚗', '🏠', '📚', '🎵', '🧩', '💊',
];

/// يفتح ورقة سفلية لإضافة رمز تواصل مخصّص (تسمية + إيموجي).
Future<void> showAddSymbolSheet(BuildContext context, AacCubit cubit) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddSymbolSheet(cubit: cubit),
  );
}

class _AddSymbolSheet extends StatefulWidget {
  final AacCubit cubit;
  const _AddSymbolSheet({required this.cubit});

  @override
  State<_AddSymbolSheet> createState() => _AddSymbolSheetState();
}

class _AddSymbolSheetState extends State<_AddSymbolSheet> {
  final _label = TextEditingController();
  String _emoji = _emojiPalette.first;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
            SizedBox(height: 16.h),
            AppText(
              text: LocaleKeys.aacAddSymbol.tr(),
              size: 18.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.mainText,
            ),
            SizedBox(height: 18.h),
            // معاينة
            Container(
              width: 72.w,
              height: 72.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.softPrimary,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Text(_emoji, style: TextStyle(fontSize: 40.sp)),
            ),
            SizedBox(height: 16.h),
            SathaField(
              controller: _label,
              label: LocaleKeys.aacSymbolLabel.tr(),
              prefixIcon: Icons.label_outline_rounded,
            ),
            SizedBox(height: 16.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 8.h),
                child: AppText(
                  text: LocaleKeys.aacPickEmoji.tr(),
                  size: 13.sp,
                  family: FontFamily.tajawalMedium,
                  color: AppColors.mainText,
                ),
              ),
            ),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _emojiPalette.map((e) {
                final selected = e == _emoji;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: Container(
                    width: 46.w,
                    height: 46.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.softPrimary : AppColors.card,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 1.8 : 1,
                      ),
                    ),
                    child: Text(e, style: TextStyle(fontSize: 22.sp)),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),
            PrimaryButton(
              text: LocaleKeys.add.tr(),
              icon: Icons.check_rounded,
              onPressed: () {
                final label = _label.text.trim();
                if (label.isEmpty) return;
                widget.cubit.addCustomSymbol(label, _emoji);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
