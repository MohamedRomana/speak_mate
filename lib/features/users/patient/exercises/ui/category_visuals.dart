import 'package:flutter/material.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../data/models/exercise_models.dart';

/// مرئيات كل فئة تمارين (أيقونة/لون/مفاتيح الترجمة).
extension ExerciseCategoryVisuals on ExerciseCategory {
  IconData get icon => switch (this) {
        ExerciseCategory.articulation => Icons.record_voice_over_rounded,
        ExerciseCategory.vocabulary => Icons.menu_book_rounded,
        ExerciseCategory.soundMatch => Icons.hearing_rounded,
        ExerciseCategory.tongueTwisters => Icons.emoji_emotions_rounded,
      };

  Color get color => switch (this) {
        ExerciseCategory.articulation => AppColors.primary,
        ExerciseCategory.vocabulary => AppColors.secondary,
        ExerciseCategory.soundMatch => AppColors.accent,
        ExerciseCategory.tongueTwisters => AppColors.warning,
      };

  String get titleKey => switch (this) {
        ExerciseCategory.articulation => LocaleKeys.catArticulation,
        ExerciseCategory.vocabulary => LocaleKeys.catVocabulary,
        ExerciseCategory.soundMatch => LocaleKeys.catSoundMatch,
        ExerciseCategory.tongueTwisters => LocaleKeys.catTongueTwisters,
      };

  String get descKey => switch (this) {
        ExerciseCategory.articulation => LocaleKeys.catArticulationDesc,
        ExerciseCategory.vocabulary => LocaleKeys.catVocabularyDesc,
        ExerciseCategory.soundMatch => LocaleKeys.catSoundMatchDesc,
        ExerciseCategory.tongueTwisters => LocaleKeys.catTongueTwistersDesc,
      };
}

extension ExerciseDifficultyVisuals on ExerciseDifficulty {
  Color get color => switch (this) {
        ExerciseDifficulty.easy => AppColors.success,
        ExerciseDifficulty.medium => AppColors.warning,
        ExerciseDifficulty.hard => AppColors.error,
      };

  String get labelKey => switch (this) {
        ExerciseDifficulty.easy => LocaleKeys.easy,
        ExerciseDifficulty.medium => LocaleKeys.medium,
        ExerciseDifficulty.hard => LocaleKeys.hard,
      };
}
