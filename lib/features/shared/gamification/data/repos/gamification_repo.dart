import 'package:flutter/material.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../models/gamification_models.dart';

/// مستودع التلعيب — mock. يوفّر المستوى/النقاط/السلسلة/الأوسمة/الأهداف اليومية.
class GamificationRepo {
  int get level => 4;
  int get xp => 320;
  int get xpToNext => 500;
  int get streakDays => 6;

  List<DailyGoal> goals() => const [
        DailyGoal(
          id: 'g_ex',
          labelKey: LocaleKeys.goalExercises,
          icon: Icons.fitness_center_rounded,
          target: 3,
          progress: 2,
        ),
        DailyGoal(
          id: 'g_ai',
          labelKey: LocaleKeys.goalSpeak,
          icon: Icons.mic_rounded,
          target: 5,
          progress: 1,
        ),
        DailyGoal(
          id: 'g_streak',
          labelKey: LocaleKeys.goalStreak,
          icon: Icons.local_fire_department_rounded,
          target: 1,
          progress: 1,
        ),
      ];

  List<AppBadge> badges() => const [
        AppBadge(id: 'b1', labelKey: LocaleKeys.badgeFirstWord, icon: Icons.star_rounded, color: AppColors.warning, earned: true),
        AppBadge(id: 'b2', labelKey: LocaleKeys.badge7Days, icon: Icons.local_fire_department_rounded, color: AppColors.error, earned: true),
        AppBadge(id: 'b3', labelKey: LocaleKeys.badgeStar, icon: Icons.auto_awesome_rounded, color: AppColors.secondary, earned: true),
        AppBadge(id: 'b4', labelKey: LocaleKeys.badgePerfect, icon: Icons.workspace_premium_rounded, color: AppColors.accent),
        AppBadge(id: 'b5', labelKey: LocaleKeys.badgeExplorer, icon: Icons.explore_rounded, color: AppColors.primary),
        AppBadge(id: 'b6', labelKey: LocaleKeys.badgeChampion, icon: Icons.emoji_events_rounded, color: AppColors.warning),
      ];
}
