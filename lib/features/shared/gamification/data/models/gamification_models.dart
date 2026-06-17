import 'package:flutter/material.dart';

/// وسام إنجاز.
class AppBadge {
  final String id;
  final String labelKey;
  final IconData icon;
  final Color color;
  final bool earned;

  const AppBadge({
    required this.id,
    required this.labelKey,
    required this.icon,
    required this.color,
    this.earned = false,
  });
}

/// هدف يومي بتقدّم.
class DailyGoal {
  final String id;
  final String labelKey;
  final IconData icon;
  final int target;
  final int progress;

  const DailyGoal({
    required this.id,
    required this.labelKey,
    required this.icon,
    required this.target,
    this.progress = 0,
  });

  bool get done => progress >= target;
  double get ratio => target == 0 ? 0 : (progress / target).clamp(0, 1);

  DailyGoal copyWith({int? progress}) => DailyGoal(
        id: id,
        labelKey: labelKey,
        icon: icon,
        target: target,
        progress: progress ?? this.progress,
      );
}
