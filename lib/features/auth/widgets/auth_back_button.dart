import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/helper/extentions.dart';
import '../../../core/helper/theme_x.dart';

/// زر رجوع دائري متّسق لشاشات المصادقة (يعكس اتجاهه في العربية).
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pop(),
      borderRadius: BorderRadius.circular(20.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: 40.w,
        height: 40.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.onBrand.withValues(alpha: 0.10),
          shape: BoxShape.circle,
          border: Border.all(color: context.onBrand.withValues(alpha: 0.2)),
        ),
        child: Transform.flip(
          flipX: context.locale.languageCode == 'ar',
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16.w,
            color: context.onBrand,
          ),
        ),
      ),
    );
  }
}
