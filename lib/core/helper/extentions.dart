import 'package:flutter/material.dart';

enum RouteAnimation {
  rightToLeft,
  leftToRight,
  bottomToTop,
  topToBottom,
  fade,
  none,
}

extension NavigationExtension on BuildContext {
  Future<dynamic> pushNamed(
    String routeName, {
    Object? arguments,
    RouteAnimation animation = RouteAnimation.none,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    if (animation == RouteAnimation.none) {
      return Navigator.of(this).pushNamed(routeName, arguments: arguments);
    } else {
      return Navigator.of(this).push(
        _buildPageRoute(
          context: this,
          routeName: routeName,
          arguments: arguments,
          animation: animation,
          duration: duration,
        ),
      );
    }
  }

  Future<dynamic> pushReplacementNamed(
    String routeName, {
    Object? arguments,
    RouteAnimation animation = RouteAnimation.none,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    if (animation == RouteAnimation.none) {
      return Navigator.of(
        this,
      ).pushReplacementNamed(routeName, arguments: arguments);
    } else {
      return Navigator.of(this).pushReplacement(
        _buildPageRoute(
          context: this,
          routeName: routeName,
          arguments: arguments,
          animation: animation,
          duration: duration,
        ),
      );
    }
  }

  Future<dynamic> pushNamedAndRemoveUntil(
    String routeName, {
    Object? arguments,
    required RoutePredicate predicate,
    RouteAnimation animation = RouteAnimation.none,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    if (animation == RouteAnimation.none) {
      return Navigator.of(
        this,
      ).pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
    } else {
      return Navigator.of(this).pushAndRemoveUntil(
        _buildPageRoute(
          context: this,
          routeName: routeName,
          arguments: arguments,
          animation: animation,
          duration: duration,
        ),
        predicate,
      );
    }
  }

  void pop([Object? result]) => Navigator.of(this).pop(result);
}

PageRouteBuilder _buildPageRoute({
  required BuildContext context,
  required String routeName,
  Object? arguments,
  required RouteAnimation animation,
  required Duration duration,
}) {
  final routes =
      (context.findAncestorWidgetOfExactType<MaterialApp>()?.routes ??
      <String, WidgetBuilder>{});

  final Widget page;
  if (routes.containsKey(routeName)) {
    page = routes[routeName]!(context);
  } else {
    final onGenerate = context
        .findAncestorWidgetOfExactType<MaterialApp>()
        ?.onGenerateRoute;
    if (onGenerate != null) {
      final generatedRoute = onGenerate(
        RouteSettings(name: routeName, arguments: arguments),
      );
      if (generatedRoute is MaterialPageRoute) {
        page = generatedRoute.builder(context);
      } else if (generatedRoute is PageRouteBuilder) {
        page = generatedRoute.pageBuilder(
          context,
          kAlwaysCompleteAnimation,
          kAlwaysDismissedAnimation,
        );
      } else {
        page = const SizedBox.shrink();
      }
    } else {
      page = const SizedBox.shrink();
    }
  }

  return PageRouteBuilder(
    settings: RouteSettings(name: routeName, arguments: arguments),
    transitionDuration: duration,
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder:
        (context, animationController, secondaryAnimation, child) {
          const curve = Curves.fastOutSlowIn;

          switch (animation) {
            case RouteAnimation.rightToLeft:
              return SlideTransition(
                position: Tween(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: curve)).animate(animationController),
                child: child,
              );
            case RouteAnimation.leftToRight:
              return SlideTransition(
                position: Tween(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: curve)).animate(animationController),
                child: child,
              );
            case RouteAnimation.bottomToTop:
              return SlideTransition(
                position: Tween(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: curve)).animate(animationController),
                child: child,
              );
            case RouteAnimation.topToBottom:
              return SlideTransition(
                position: Tween(
                  begin: const Offset(0.0, -1.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: curve)).animate(animationController),
                child: child,
              );
            case RouteAnimation.fade:
              return FadeTransition(opacity: animationController, child: child);
            case RouteAnimation.none:
              return child;
          }
        },
  );
}

extension ListExtension<T> on List<T>? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;
}

extension StringExtension on String? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;
}
