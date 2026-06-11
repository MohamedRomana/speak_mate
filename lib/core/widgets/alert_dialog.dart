// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/fonts.gen.dart';
import '../constants/colors.dart';
import 'app_text.dart';
import 'custom_lottie_widget.dart';

customAlertDialog({
  required BuildContext context,
  required Widget child,
  Color? barrierColor,
  Color? dialogShadowColor,
  Color? titleTextColor,
  Color? dialogBackGroundColor,
  Color? dialogSurfaceTintColor,
  double? alertDialogHeight,
  double? alertDialogWidth,
  double? blurSigmaX,
  double? dialogElevation,
  double? blurSigmaY,
  EdgeInsetsGeometry? blurOutSidePadding,
  Widget? contentTextWidget,
  Widget? customWidget,
  EdgeInsetsGeometry? contentTextPadding,
  EdgeInsetsGeometry? customWidgetPadding,
  AlignmentGeometry? dialogAlignment,
  EdgeInsets? dialogInsetsPadding,
  ShapeBorder? dialogShape,
  bool? contentScroll = false,
  EdgeInsetsGeometry? dialogContentPadding,
  bool? barrierDismissible,
}) {
  showGeneralDialog(
    barrierColor: barrierColor ?? Colors.black.withOpacity(0.5),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurSigmaX ?? 5.0,
            sigmaY: blurSigmaY ?? 5.0,
          ),
          child: AlertDialog(
            alignment: dialogAlignment ?? Alignment.center,
            backgroundColor: dialogBackGroundColor ?? Colors.white,
            surfaceTintColor: dialogSurfaceTintColor ?? Colors.transparent,
            shadowColor: dialogShadowColor ?? Colors.transparent,
            elevation: dialogElevation ?? 0,
            insetPadding:
                dialogInsetsPadding ??
                const EdgeInsets.symmetric(horizontal: 0),
            contentPadding:
                dialogContentPadding ?? EdgeInsets.symmetric(horizontal: 16.w),
            shape:
                dialogShape ??
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
            buttonPadding: EdgeInsets.zero,
            content: Material(
              elevation: dialogElevation ?? 0,
              shape:
                  dialogShape ??
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
              color: dialogBackGroundColor ?? Colors.white,
              surfaceTintColor: dialogSurfaceTintColor ?? Colors.transparent,
              child: SizedBox(
                height: alertDialogHeight ?? 265.h,
                width: alertDialogWidth ?? double.infinity,
                child: child,
              ),
            ),
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
    barrierDismissible: barrierDismissible ?? true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return const SizedBox();
    },
  );
}

showLoadingDialog({
  required BuildContext context,
  String? text,
  bool isLottie = false,
  String? loadingText,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        titlePadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        backgroundColor: isLottie ? Colors.transparent : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Column(
          children: [
            isLottie
                ? const CustomLottieWidget()
                : Column(
                    children: [
                      const CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 16.h),
                      AppText(
                        text: loadingText ?? "Loading...",
                        color: AppColors.primary,
                        family: FontFamily.tajawalRegular,
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
          ],
        ),
      );
    },
  );
}
