// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/colors.dart';

class CustomShimmer extends StatelessWidget {
  final double? height;
  final double? width;
  final double? radius;
  final Decoration? decoration;
  final Widget? child;

  const CustomShimmer({
    super.key,
    this.height,
    this.width,
    this.radius,
    this.decoration,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.primary.withOpacity(0.2),
      highlightColor: AppColors.primary.withOpacity(0.1),
      child: child ??
          Container(
            height: height ?? 150.h,
            width: width ?? 150.w,
            decoration: decoration ??
                BoxDecoration(
                  borderRadius: BorderRadius.circular(radius ?? 15.w),
                  color: Colors.grey,
                ),
          ),
    );
  }
}
