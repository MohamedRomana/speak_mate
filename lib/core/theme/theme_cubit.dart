import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cache/cache_helper.dart';

/// كيوبت إدارة وضع الثيم (دارك/لايت/تبع النظام) مع حفظه محليًا.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_fromCache());

  static ThemeMode _fromCache() {
    switch (CacheHelper.getThemeMode()) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  void setMode(ThemeMode mode) {
    CacheHelper.setThemeMode(mode.name);
    emit(mode);
  }

  /// تبديل بين الداكن والفاتح اعتمادًا على السطوع الحالي الفعّال.
  void toggle(bool currentlyDark) {
    setMode(currentlyDark ? ThemeMode.light : ThemeMode.dark);
  }
}
