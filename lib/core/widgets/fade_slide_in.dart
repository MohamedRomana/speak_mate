import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Direction the child slides in from while fading in.
enum SlideFrom { bottom, top, start, end, none }

/// A lightweight entrance animation that fades + slides its [child] into place.
///
/// Use it to give texts, cards and containers a pleasant entrance.
/// Stagger multiple widgets by giving each an increasing [delay].
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final SlideFrom from;
  final double offset;
  final double beginScale;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.from = SlideFrom.bottom,
    this.offset = 30,
    this.beginScale = 1.0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Offset _beginOffset() {
    switch (widget.from) {
      case SlideFrom.bottom:
        return Offset(0, widget.offset.h);
      case SlideFrom.top:
        return Offset(0, -widget.offset.h);
      case SlideFrom.start:
        return Offset(-widget.offset.w, 0);
      case SlideFrom.end:
        return Offset(widget.offset.w, 0);
      case SlideFrom.none:
        return Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        final begin = _beginOffset();
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(begin.dx * (1 - t), begin.dy * (1 - t)),
            child: Transform.scale(
              scale: widget.beginScale + (1 - widget.beginScale) * t,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
