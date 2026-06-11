import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/fonts.gen.dart';
import '../constants/colors.dart';

class AppInput extends StatelessWidget {
  final void Function(String?)? onChanged;
  final void Function()? onTap;
  final void Function(String?)? onSubmitted;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validate;
  final FocusNode? focusNode;
  final bool? read;
  final bool? filled;
  final Widget? prefixIcon;
  final int? maxLines;
  final Widget? suffixIcon;
  final double? start;
  final double? end;
  final double? top;
  final double? bottom;
  final TextInputType? inputType;
  final String? label;
  final String? hint;
  final bool? secureText;
  final bool? isEnabled;
  final bool? autofocus;
  final Color? color;
  final Color? iconColor;
  final Color? hintColor;
  final TextEditingController? controller;
  final Color? borderColorr;
  final double? contentLeft;
  final double? contentRight;
  final double? contentTop;
  final double? contentBottom;
  final Color? outLineInputColorColor;
  final Color? enabledBorderColor;
  final Color? disableBorderColor;
  final Color? errorBorderColor;
  final Color? focusedBorderColor;
  final Color? focusedErrorBorderColor;
  final Color? cursorColor;
  final BoxConstraints? prefixSize;
  final BoxConstraints? suffixSize;
  final double? border;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final Color? labelColor;
  final Color? inputColor;

  const AppInput({
    super.key,
    this.onChanged,
    this.validate,
    this.prefixIcon,
    this.suffixIcon,
    this.inputType,
    this.label,
    this.hint,
    this.secureText,
    this.onSubmitted,
    this.isEnabled = true,
    this.controller,
    this.color,
    this.onSaved,
    this.autofocus,
    this.iconColor,
    this.borderColorr,
    this.contentLeft,
    this.contentRight,
    this.contentTop,
    this.contentBottom,
    this.start,
    this.end,
    this.top,
    this.bottom,
    this.enabledBorderColor,
    this.maxLines,
    this.border,
    this.outLineInputColorColor,
    this.disableBorderColor,
    this.errorBorderColor,
    this.focusedBorderColor,
    this.focusedErrorBorderColor,
    this.onTap,
    this.read,
    this.prefixSize,
    this.suffixSize,
    this.filled,
    this.hintColor,
    this.textInputAction,
    this.cursorColor,
    this.contentPadding,
    this.focusNode,
    this.labelColor,
    this.inputColor,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: start ?? 20.w,
        end: end ?? 20.w,
        top: top ?? 0,
        bottom: bottom ?? 0,
      ),
      child: TextFormField(
        focusNode: focusNode,
        readOnly: read ?? false,
        onTap: onTap,
        maxLines: maxLines ?? 1,
        enabled: isEnabled ?? true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        onFieldSubmitted: onSubmitted,
        style: TextStyle(color: inputColor ?? Colors.white, fontSize: 16.sp),
        obscureText: secureText ?? false,
        cursorColor: cursorColor ?? Colors.white,
        keyboardType: inputType ?? TextInputType.text,
        textInputAction: textInputAction ?? TextInputAction.next,
        validator: validate,
        onSaved: onSaved,
        autofocus: autofocus ?? false,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(border ?? 51.r),
            borderSide: BorderSide(
              // width: .1.w,
              color: enabledBorderColor ?? AppColors.primary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(border ?? 51.r),
            borderSide: BorderSide(color: focusedBorderColor ?? Colors.white),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(border ?? 51.r),
            borderSide: BorderSide(
              color: errorBorderColor ?? AppColors.darkRed,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(border ?? 51.r),
            borderSide: BorderSide(
              color: focusedErrorBorderColor ?? AppColors.darkRed,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(border ?? 51.r),
            borderSide: BorderSide(color: disableBorderColor ?? Colors.white),
          ),
          contentPadding:
              contentPadding ??
              EdgeInsets.symmetric(
                vertical: contentTop ?? 12.h,
                horizontal: contentRight ?? 10.w,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(border ?? 51.r),
            borderSide: BorderSide(
              color: outLineInputColorColor ?? Colors.white,
            ),
          ),
          filled: filled ?? false,
          fillColor: color ?? AppColors.borderColor.withAlpha(30),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          // prefixIconConstraints:
          //     prefixSize ?? BoxConstraints(maxHeight: 35.h, maxWidth: 45.w),
          // suffixIconConstraints:
          //     suffixSize ?? BoxConstraints(maxHeight: 35.h, maxWidth: 60.w),
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14.sp,
            color: labelColor ?? Colors.white,
            fontFamily: FontFamily.tajawalRegular,
          ),
          hintStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.width >= 600 ? 12.sp : 14.sp,
            color: hintColor ?? Colors.grey,
            fontFamily: FontFamily.tajawalRegular,
          ),
          hintText: hint,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
