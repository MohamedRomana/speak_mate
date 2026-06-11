import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../gen/assets.gen.dart';
import '../../gen/fonts.gen.dart';
import '../constants/colors.dart';
import 'app_text.dart';
import 'fade_slide_in.dart';

/// A reusable empty-state widget: a Lottie animation with a message under it.
///
/// Shown whenever a list/section comes back empty.
class EmptyDataWidget extends StatelessWidget {
  final String message;
  final String? lottieName;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const EmptyDataWidget({
    super.key,
    required this.message,
    this.lottieName,
    this.height,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? EdgeInsets.symmetric(vertical: 40.h, horizontal: 16.w),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeSlideIn(
              from: SlideFrom.none,
              beginScale: 0.85,
              duration: const Duration(milliseconds: 600),
              child: Lottie.asset(
                lottieName ?? Assets.img.emptyorder,
                height: height ?? 180.w,
                width: width ?? 180.w,
                repeat: true,
                animate: true,
                fit: BoxFit.contain,
              ),
            ),
            FadeSlideIn(
              from: SlideFrom.bottom,
              delay: const Duration(milliseconds: 250),
              child: AppText(
                text: message,
                size: 18.sp,
                textAlign: TextAlign.center,
                color: AppColors.primary,
                family: FontFamily.tajawalBold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
