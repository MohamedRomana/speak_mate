import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/fonts.gen.dart';
import '../constants/colors.dart';

/// قائمة منسدلة بنفس ستايل [SathaField] (بطاقة فاتحة) مع دعم التحقق.
class SathaDropdown<T> extends StatelessWidget {
  final String? label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;

  const SathaDropdown({
    super.key,
    this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: 8.h, start: 4.w),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.mainText,
                fontFamily: FontFamily.tajawalMedium,
              ),
            ),
          ),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.secondaryText),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondaryText,
              fontFamily: FontFamily.tajawalRegular,
            ),
          ),
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.mainText,
            fontFamily: FontFamily.tajawalMedium,
          ),
          items: items,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightBg,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: AppColors.secondaryText, size: 20.w),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.orange, width: 1.6),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, width: 1.6),
            errorStyle: TextStyle(fontSize: 11.sp, color: AppColors.error),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
