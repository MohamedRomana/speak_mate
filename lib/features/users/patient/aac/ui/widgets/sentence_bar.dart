import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/logic/action_state.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../gen/fonts.gen.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../logic/aac_cubit.dart';

/// شريط الجملة المكوّنة + أزرار النطق/الحذف/المسح.
class SentenceBar extends StatelessWidget {
  const SentenceBar({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    return BlocBuilder<AacCubit, ActionState>(
      builder: (context, _) {
        final cubit = context.read<AacCubit>();
        final sentence = cubit.sentence;
        return Container(
          margin: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 60.h,
                child: sentence.isEmpty
                    ? Center(
                        child: AppText(
                          text: LocaleKeys.aacEmptyHint.tr(),
                          size: 13.sp,
                          color: AppColors.secondaryText,
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: sentence.length,
                        separatorBuilder: (_, __) => SizedBox(width: 8.w),
                        itemBuilder: (context, i) => _Chip(
                          emoji: sentence[i].emoji,
                          label: sentence[i].label(lang),
                        ),
                      ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(child: _SpeakButton(cubit: cubit)),
                  SizedBox(width: 8.w),
                  _RoundBtn(
                    icon: Icons.backspace_outlined,
                    onTap: cubit.backspace,
                  ),
                  SizedBox(width: 8.w),
                  _RoundBtn(
                    icon: Icons.delete_sweep_outlined,
                    danger: true,
                    onTap: cubit.clearSentence,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String emoji;
  final String label;
  const _Chip({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.softPrimary,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 22.sp)),
          AppText(
            text: label,
            size: 10.sp,
            color: AppColors.primary,
            family: FontFamily.tajawalMedium,
          ),
        ],
      ),
    );
  }
}

class _SpeakButton extends StatelessWidget {
  final AacCubit cubit;
  const _SpeakButton({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final speaking = cubit.speaking;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        cubit.speak();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: speaking
                ? [AppColors.accent, const Color(0xff2AA98C)]
                : [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              speaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 22.w,
            ),
            SizedBox(width: 8.w),
            AppText(
              text: (speaking ? LocaleKeys.aacSpeaking : LocaleKeys.aacSpeak)
                  .tr(),
              size: 14.sp,
              family: FontFamily.tajawalBold,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;
  const _RoundBtn({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.secondaryText;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 48.h,
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: color, size: 22.w),
      ),
    );
  }
}
