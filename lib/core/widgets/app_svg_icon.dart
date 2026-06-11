import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// أيقونة SVG موحّدة مع انتقال لوني متحرّك (للحالات النشطة/غير النشطة).
class AppSvgIcon extends StatelessWidget {
  final String assetPath;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final Duration duration;

  const AppSvgIcon({
    super.key,
    required this.assetPath,
    this.size,
    this.color,
    this.semanticLabel,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 24.w;
    return TweenAnimationBuilder<Color?>(
      duration: duration,
      curve: Curves.easeOut,
      tween: ColorTween(begin: color, end: color),
      builder: (context, animatedColor, _) {
        return SvgPicture.asset(
          assetPath,
          width: dimension,
          height: dimension,
          semanticsLabel: semanticLabel,
          colorFilter: animatedColor == null
              ? null
              : ColorFilter.mode(animatedColor, BlendMode.srcIn),
          fit: BoxFit.contain,
        );
      },
    );
  }
}
