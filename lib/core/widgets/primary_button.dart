import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/fonts.gen.dart';
import '../constants/colors.dart';
import '../constants/gradients.dart';

/// زر CTA أساسي بتدرّج برتقالي يدعم: عادي / مضغوط / تحميل / معطّل / نجاح.
class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final bool success;
  final bool enabled;
  final IconData? icon;
  final double? width;
  final Gradient? gradient;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.success = false,
    this.enabled = true,
    this.icon,
    this.width,
    this.gradient,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _disabled => !widget.enabled || widget.loading || widget.success;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _disabled ? null : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: _disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 54.h,
          width: widget.width ?? double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: _disabled && !widget.success
                ? null
                : (widget.success
                      ? const LinearGradient(
                          colors: [AppColors.success, AppColors.success],
                        )
                      : (widget.gradient ?? AppGradients.orange)),
            color: _disabled && !widget.success ? AppColors.border : null,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: _disabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildChild(),
          ),
        ),
      ),
    );
  }

  Widget _buildChild() {
    if (widget.loading) {
      return SizedBox(
        key: const ValueKey('loading'),
        width: 24.w,
        height: 24.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2.4,
          color: Colors.white,
        ),
      );
    }
    if (widget.success) {
      return Icon(
        Icons.check_rounded,
        key: const ValueKey('success'),
        color: Colors.white,
        size: 26.w,
      );
    }
    return Row(
      key: const ValueKey('text'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: Colors.white, size: 20.w),
          SizedBox(width: 8.w),
        ],
        Text(
          widget.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontFamily: FontFamily.tajawalBold,
          ),
        ),
      ],
    );
  }
}

/// زر ثانوي بإطار (outline) — للروابط الثانوية مثل "إنشاء حساب".
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color color;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color = AppColors.navy,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: OutlinedButton.icon(
        onPressed: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        icon: icon == null
            ? const SizedBox.shrink()
            : Icon(icon, color: color, size: 20.w),
        label: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 15.sp,
            fontFamily: FontFamily.tajawalBold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}
