import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helper/theme_x.dart';
import '../../../../../core/widgets/fade_slide_in.dart';
import '../../../../../gen/fonts.gen.dart';

/// بيانات صفحة onboarding واحدة.
class OnboardingData {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const OnboardingData({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });
}

/// صفحة onboarding: أيقونة داخل دائرة متدرّجة نابضة + عنوان ووصف متحرّكين.
class OnboardingPage extends StatefulWidget {
  final OnboardingData data;
  const OnboardingPage({super.key, required this.data});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.data.color;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              final t = 0.5 + (_pulse.value * 0.5);
              return Container(
                width: 220.w,
                height: 220.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      c.withValues(alpha: 0.22 * t),
                      c.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: child,
              );
            },
            child: Container(
              width: 130.w,
              height: 130.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c, c.withValues(alpha: 0.65)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: c.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(widget.data.icon, size: 60.w, color: Colors.white),
            ),
          ),
          SizedBox(height: 48.h),
          FadeSlideIn(
            key: ValueKey('title_${widget.data.title}'),
            from: SlideFrom.bottom,
            child: Text(
              widget.data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontFamily: FontFamily.tajawalBold,
                color: context.onBrand,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          FadeSlideIn(
            key: ValueKey('desc_${widget.data.desc}'),
            from: SlideFrom.bottom,
            delay: const Duration(milliseconds: 120),
            child: Text(
              widget.data.desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.6,
                fontFamily: FontFamily.tajawalRegular,
                color: context.onBrandMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
