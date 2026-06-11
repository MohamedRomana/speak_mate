import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/colors.dart';
import '../../../core/helper/theme_x.dart';
import '../../../gen/assets.gen.dart';

/// صفّ أزرار تسجيل الدخول الاجتماعي (Google / Apple).
class SocialLoginRow extends StatelessWidget {
  final ValueChanged<String> onProvider;
  const SocialLoginRow({super.key, required this.onProvider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          asset: Assets.svg.google,
          onTap: () => onProvider('google'),
        ),
        SizedBox(width: 16.w),
        _SocialButton(
          asset: Assets.svg.applePay,
          tint: context.onBrand,
          onTap: () => onProvider('apple'),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  final Color? tint;

  const _SocialButton({required this.asset, required this.onTap, this.tint});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: 64.w,
        height: 52.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: SvgPicture.asset(
          asset,
          width: 24.w,
          height: 24.w,
          colorFilter: tint == null
              ? null
              : ColorFilter.mode(tint!, BlendMode.srcIn),
        ),
      ),
    );
  }
}

/// فاصل "أو تابع باستخدام" بخطّين وكلمة في المنتصف.
class OrDivider extends StatelessWidget {
  final String text;
  const OrDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = context.onBrandMuted;
    return Row(
      children: [
        Expanded(child: Divider(color: color.withValues(alpha: 0.3))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: color),
          ),
        ),
        Expanded(child: Divider(color: color.withValues(alpha: 0.3))),
      ],
    );
  }
}
