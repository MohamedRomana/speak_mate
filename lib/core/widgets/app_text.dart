// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppText extends StatelessWidget {
  final String text;
  final String? family;
  final double? size;
  final double? start;
  final double? top;
  final double? end;
  final double? bottom;
  final Color? color;
  final int? lines;
  final FontWeight? fontWeight;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final FontStyle? fontStyle;
  final TextDecoration? decoration;
  final Color? decorationColor;

  const AppText({
    super.key,
    required this.text,
    this.family,
    this.size,
    this.color,
    this.lines,
    this.overflow,
    this.start,
    this.top,
    this.end,
    this.bottom,
    this.fontWeight,
    this.textAlign,
    this.fontStyle,
    this.decoration,
    this.decorationColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: start ?? 0,
        end: end ?? 0,
        top: top ?? 0,
        bottom: bottom ?? 0,
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontWeight: fontWeight,
          fontFamily: family,
          fontSize: size ?? 16.sp,
          color: color ?? Colors.black,
          fontStyle: fontStyle ?? FontStyle.normal,
          decoration: decoration,
          decorationColor: decorationColor ?? color,
        ),
        maxLines: lines,
        overflow: overflow ?? TextOverflow.ellipsis,
      ),
    );
  }
}
