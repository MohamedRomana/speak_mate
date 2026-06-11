import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDivider extends StatelessWidget {
  final double? start;
  final double? end;
  final double? bottom;
  final double? top;
  final Color? color;

  const AppDivider({
    super.key,
    this.start,
    this.end,
    this.bottom,
    this.top,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: start ?? 0,
        top: top ?? 0,
        end: end ?? 0,
        bottom: bottom ?? 0,
      ),
      child: Container(
        height: 1.h,
        width: double.infinity,
        color: color ?? const Color(0xffD8D8D8),
      ),
    );
  }
}
