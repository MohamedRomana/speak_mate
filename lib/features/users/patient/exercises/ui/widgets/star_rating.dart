import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/colors.dart';

/// عرض نجوم متحرّك (يملأ النجوم المكتسبة بتتابع نابض).
class StarRating extends StatelessWidget {
  final int stars; // 0..3
  final double size;
  const StarRating({super.key, required this.stars, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final earned = i < stars;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: earned ? 1 : 0.5),
          duration: Duration(milliseconds: 350 + i * 180),
          curve: Curves.elasticOut,
          builder: (context, v, _) => Transform.scale(
            scale: earned ? v : 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Icon(
                earned ? Icons.star_rounded : Icons.star_outline_rounded,
                size: size.w,
                color: earned ? AppColors.warning : AppColors.border,
              ),
            ),
          ),
        );
      }),
    );
  }
}
