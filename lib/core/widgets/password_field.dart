import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import 'satha_field.dart';

/// حقل كلمة مرور قابل لإعادة الاستخدام مع أيقونة عين متحركة (إظهار/إخفاء).
class SathaPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction textInputAction;

  const SathaPasswordField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<SathaPasswordField> createState() => _SathaPasswordFieldState();
}

class _SathaPasswordFieldState extends State<SathaPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return SathaField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      prefixIcon: Icons.lock_outline_rounded,
      obscure: _obscure,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      suffix: IconButton(
        splashRadius: 20.r,
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            _obscure
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            key: ValueKey(_obscure),
            color: AppColors.secondaryText,
            size: 20.w,
          ),
        ),
      ),
    );
  }
}
