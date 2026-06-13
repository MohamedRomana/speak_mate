import 'package:flutter/material.dart';

import '../constants/colors.dart';

/// يبني مسارًا موحّدًا (انتقال fade + slide خفيف) **ويلفّ الشاشة** بـ
/// [ValueListenableBuilder] على [AppColors.uiNotifier] مع [KeyedSubtree]، بحيث
/// تعيد كل شاشة بناء نفسها فورًا عند تبديل الثيم/التباين — في كل التطبيق دفعة واحدة.
PageRouteBuilder<T> buildAppRoute<T>(Widget child, {RouteSettings? settings}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, animation, secondaryAnimation) =>
        ValueListenableBuilder<int>(
      valueListenable: AppColors.uiNotifier,
      builder: (context, rev, _) =>
          KeyedSubtree(key: ValueKey(rev), child: child),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, c) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: c,
        ),
      );
    },
  );
}
