import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/assets.gen.dart';
import '../constants/colors.dart';
import '../helper/theme_x.dart';

/// شعار سطحة الشفّاف — يختار النسخة المناسبة للثيم تلقائيًا:
/// الوضع الداكن ⇐ اللوجو الأبيض، الوضع الفاتح ⇐ لوجو الـ navy.
/// يمكن إجبار نسخة معيّنة عبر [forceWhite].
class AppLogo extends StatelessWidget {
  final double? size;
  final bool hero;
  final bool? forceWhite;
  const AppLogo({super.key, this.size, this.hero = true, this.forceWhite});

  @override
  Widget build(BuildContext context) {
    final useWhite = forceWhite ?? context.isDark;
    final image = Image.asset(
      useWhite ? Assets.img.logoWhite.path : Assets.img.logo.path,
      width: size ?? 110.w,
      height: size ?? 110.w,
      fit: BoxFit.contain,
    );
    return hero ? Hero(tag: 'satha_logo', child: image) : image;
  }
}

/// شعار متحرّك: دخول بـ fade + scale مع توهّج برتقالي ناعم نابض خلفه.
class AnimatedAppLogo extends StatefulWidget {
  final double? size;
  final bool glow;
  final bool hero;
  const AnimatedAppLogo({super.key, this.size, this.glow = true, this.hero = true});

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _entry.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? 120.w;
    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _pulse]),
      builder: (context, child) {
        final entry = Curves.easeOutBack.transform(_entry.value.clamp(0, 1));
        final glowT = 0.5 + (_pulse.value * 0.5);
        return Opacity(
          opacity: _entry.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.7 + (0.3 * entry),
            child: Container(
              width: size * 1.5,
              height: size * 1.5,
              alignment: Alignment.center,
              decoration: widget.glow
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.orange.withValues(alpha: 0.30 * glowT),
                          AppColors.orange.withValues(alpha: 0.0),
                        ],
                      ),
                    )
                  : null,
              child: child,
            ),
          ),
        );
      },
      child: AppLogo(size: size, hero: widget.hero),
    );
  }
}
