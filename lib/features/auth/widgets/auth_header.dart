import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/helper/theme_x.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../gen/fonts.gen.dart';

/// رأس شاشات المصادقة: شعار + عنوان + وصف، بدخول متدرّج.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogo;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLogo) ...[
          Center(child: AnimatedAppLogo(size: 84.w)),
          SizedBox(height: 20.h),
        ],
        FadeSlideIn(
          from: SlideFrom.start,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 26.sp,
              fontFamily: FontFamily.tajawalBold,
              color: context.onBrand,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        FadeSlideIn(
          from: SlideFrom.start,
          delay: const Duration(milliseconds: 120),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              fontFamily: FontFamily.tajawalRegular,
              color: context.onBrandMuted,
            ),
          ),
        ),
      ],
    );
  }
}
