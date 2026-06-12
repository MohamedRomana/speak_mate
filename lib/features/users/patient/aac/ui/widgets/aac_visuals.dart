import 'package:flutter/material.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../data/models/aac_symbol.dart';

/// مرئيات فئات لوح التواصل (أيقونة/لون/مفتاح الترجمة).
extension AacCategoryVisuals on AacCategory {
  IconData get icon => switch (this) {
        AacCategory.basics => Icons.star_rounded,
        AacCategory.food => Icons.restaurant_rounded,
        AacCategory.feelings => Icons.mood_rounded,
        AacCategory.actions => Icons.directions_run_rounded,
        AacCategory.places => Icons.place_rounded,
        AacCategory.mine => Icons.bookmark_rounded,
      };

  Color get color => switch (this) {
        AacCategory.basics => AppColors.primary,
        AacCategory.food => AppColors.accent,
        AacCategory.feelings => AppColors.warning,
        AacCategory.actions => AppColors.secondary,
        AacCategory.places => AppColors.success,
        AacCategory.mine => AppColors.error,
      };

  String get labelKey => switch (this) {
        AacCategory.basics => LocaleKeys.aacCatBasics,
        AacCategory.food => LocaleKeys.aacCatFood,
        AacCategory.feelings => LocaleKeys.aacCatFeelings,
        AacCategory.actions => LocaleKeys.aacCatActions,
        AacCategory.places => LocaleKeys.aacCatPlaces,
        AacCategory.mine => LocaleKeys.aacCatMine,
      };
}
