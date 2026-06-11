import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/fonts.gen.dart';
import '../constants/colors.dart';

/// حقل إدخال أنيق بحدود متحركة عند التركيز — أساس فورمات سطحة (على بطاقة فاتحة).
class SathaField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscure;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool enabled;
  final bool autofocus;

  const SathaField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  State<SathaField> createState() => _SathaFieldState();
}

class _SathaFieldState extends State<SathaField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: 8.h, start: 4.w),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.mainText,
                fontFamily: FontFamily.tajawalMedium,
              ),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _focused ? AppColors.card : AppColors.lightBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _focused ? AppColors.orange : AppColors.border,
              width: _focused ? 1.6 : 1,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscure,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            onChanged: widget.onChanged,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            cursorColor: AppColors.orange,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.mainText,
              fontFamily: FontFamily.tajawalMedium,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.secondaryText,
                fontFamily: FontFamily.tajawalRegular,
              ),
              prefixIcon: widget.prefixIcon == null
                  ? null
                  : Icon(
                      widget.prefixIcon,
                      color: _focused ? AppColors.orange : AppColors.secondaryText,
                      size: 20.w,
                    ),
              suffixIcon: widget.suffix,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              errorStyle: TextStyle(
                fontSize: 11.sp,
                color: AppColors.error,
                fontFamily: FontFamily.tajawalRegular,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// حقل رقم جوال (أرقام فقط).
class SathaPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const SathaPhoneField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return SathaField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.phone_iphone_rounded,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      validator: validator,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}
