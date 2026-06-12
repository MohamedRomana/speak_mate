import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../../core/constants/colors.dart';

/// تأثير احتفال بسيط — جُسيمات ملوّنة تتساقط وتتلاشى (بدون حزمة خارجية).
class ConfettiOverlay extends StatefulWidget {
  final int particles;
  const ConfettiOverlay({super.key, this.particles = 60});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  late final List<_Particle> _items;

  static const _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    AppColors.warning,
    AppColors.error,
  ];

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    _items = List.generate(widget.particles, (i) {
      return _Particle(
        x: rnd.nextDouble(),
        startY: -0.1 - rnd.nextDouble() * 0.3,
        size: 6 + rnd.nextDouble() * 8,
        color: _colors[rnd.nextInt(_colors.length)],
        drift: (rnd.nextDouble() - 0.5) * 0.3,
        rotationSpeed: (rnd.nextDouble() - 0.5) * 8,
        delay: rnd.nextDouble() * 0.4,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(_items, _controller.value),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x;
  final double startY;
  final double size;
  final Color color;
  final double drift;
  final double rotationSpeed;
  final double delay;

  _Particle({
    required this.x,
    required this.startY,
    required this.size,
    required this.color,
    required this.drift,
    required this.rotationSpeed,
    required this.delay,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> items;
  final double t;
  _ConfettiPainter(this.items, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in items) {
      final localT = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final y = (p.startY + localT * 1.3) * size.height;
      final x = (p.x + p.drift * localT) * size.width;
      final opacity = (1 - localT).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(localT * p.rotationSpeed);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
