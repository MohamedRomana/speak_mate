import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';

/// مربّع اختيار متحرّك مع نص اختياري — يُستخدم للشروط و"تذكرني".
class AnimatedCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? label;

  const AnimatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              color: value ? AppColors.orange : Colors.transparent,
              borderRadius: BorderRadius.circular(7.r),
              border: Border.all(
                color: value ? AppColors.orange : AppColors.secondaryText,
                width: 1.6,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: value
                  ? Icon(
                      Icons.check_rounded,
                      key: const ValueKey('checked'),
                      size: 16.w,
                      color: Colors.white,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          if (label != null) ...[
            SizedBox(width: 10.w),
            Flexible(child: label!),
          ],
        ],
      ),
    );
  }
}
