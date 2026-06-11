import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../helper/theme_x.dart';
import '../theme/theme_cubit.dart';

/// زر تبديل الثيم (دارك/لايت) — يتكيّف لونه مع الخلفية ويبدّل الأيقونة بأنميشن.
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final fg = context.onBrand;
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () => context.read<ThemeCubit>().toggle(dark),
      child: Container(
        width: 40.w,
        height: 40.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: (dark ? Colors.white : AppColors.navy).withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: fg.withValues(alpha: 0.25)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(dark),
            color: fg,
            size: 18.w,
          ),
        ),
      ),
    );
  }
}
