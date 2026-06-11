import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void customBottomSheet({
  required BuildContext context,
  required Widget child,
  bool enableDrag = true,
  bool isDismissible = true,
  bool isScrollControlled = false
}) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
    ),
    backgroundColor: Colors.white,
    barrierColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    isDismissible: isDismissible,
    useRootNavigator: true,
    enableDrag: enableDrag,
    elevation: 0,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 5.0,
        sigmaY: 5.0,
      ),
      child: child,
    ),
  );
}
