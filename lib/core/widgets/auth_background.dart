import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../helper/theme_x.dart';

/// خلفية متحرّكة هادئة بهوية SpeakMate: تدرّج Serene + فقاعات لون ناعمة تطفو
/// ببطء + موجة صوت رقيقة — حركة لطيفة لا تشتّت المحتوى.
class AnimatedAuthBackground extends StatefulWidget {
  final Widget child;
  const AnimatedAuthBackground({super.key, required this.child});

  @override
  State<AnimatedAuthBackground> createState() => _AnimatedAuthBackgroundState();
}

class _AnimatedAuthBackgroundState extends State<AnimatedAuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: context.brandGradient),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          return Stack(
            children: [
              Positioned(
                top: -50 + (24 * math.sin(t * 2 * math.pi)),
                right: -40,
                child: _blob(220, AppColors.primary.withValues(alpha: 0.20)),
              ),
              Positioned(
                bottom: -70 - (24 * math.sin(t * 2 * math.pi)),
                left: -50,
                child: _blob(250, AppColors.secondary.withValues(alpha: 0.18)),
              ),
              Positioned(
                top: 180 + (16 * math.cos(t * 2 * math.pi)),
                left: -30,
                child: _blob(120, AppColors.accent.withValues(alpha: 0.14)),
              ),
              Positioned.fill(
                child: CustomPaint(painter: _SoundWavePainter(t)),
              ),
              child!,
            ],
          );
        },
        child: widget.child,
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

/// موجة صوت رقيقة تتموّج أفقيًا — لمسة "تخاطب" خفيفة.
class _SoundWavePainter extends CustomPainter {
  final double progress;
  _SoundWavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.06)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final y = size.height * 0.5;
    final path = Path()..moveTo(0, y);
    for (double x = 0; x <= size.width; x += 6) {
      final phase = (x / size.width * 4 * math.pi) + (progress * 2 * math.pi);
      final amp = 10 * math.sin(phase) * math.sin(x / size.width * math.pi);
      path.lineTo(x, y + amp);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SoundWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
