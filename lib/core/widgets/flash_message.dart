// ignore_for_file: deprecated_member_use

import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/assets.gen.dart';
import '../constants/colors.dart';
import 'app_text.dart';

enum FlashMessageType { success, error, warning }

Color chooseFlashBckColor(FlashMessageType type) {
  Color color;
  switch (type) {
    case FlashMessageType.success:
      color = AppColors.primary.withOpacity(0.8);
      break;
    case FlashMessageType.error:
      color = Colors.red.withOpacity(0.8);
      break;
    case FlashMessageType.warning:
      color = Colors.amber.withOpacity(0.8);
      break;
  }

  return color;
}

void showFlashMessage({
  required String message,
  required FlashMessageType type,
  required BuildContext context,
  Color? textColor,
  FlashPosition position = FlashPosition.bottom,
}) {
  showFlash(
    context: context,
    duration: const Duration(seconds: 3),
    builder: (context, controller) {
      return Flash(
        controller: controller,
        position: FlashPosition.bottom,
        child: FlashBar(
          controller: controller,
          backgroundColor: chooseFlashBckColor(type),
          elevation: 6,
          margin: EdgeInsets.symmetric(horizontal: 55.w, vertical: 70.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
          icon: Container(
            height: 35.w,
            width: 35.w,
            margin: EdgeInsetsDirectional.only(start: 16.w),
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Image.asset(Assets.img.logo.path, fit: BoxFit.fill),
          ),
          behavior: FlashBehavior.fixed,
          position: position,
          showProgressIndicator: false,
          shadowColor: Colors.black38,
          primaryAction: null,
          useSafeArea: false,
          content: AppText(
            text: message,
            color: textColor ?? Colors.white,
            lines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      );
    },
  );
}
