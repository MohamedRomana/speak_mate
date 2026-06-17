import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/gamification_models.dart';
import '../data/repos/gamification_repo.dart';

/// كيوبت التلعيب — مستوى/نقاط/سلسلة/أوسمة/أهداف. الحالة عدّاد إصدار.
class GamificationCubit extends Cubit<int> {
  final GamificationRepo _repo;
  GamificationCubit(this._repo) : super(0);

  int level = 1;
  int xp = 0;
  int xpToNext = 500;
  int streakDays = 0;
  List<DailyGoal> goals = [];
  List<AppBadge> badges = [];

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  void load() {
    level = _repo.level;
    xp = _repo.xp;
    xpToNext = _repo.xpToNext;
    streakDays = _repo.streakDays;
    goals = _repo.goals();
    badges = _repo.badges();
    _emit();
  }

  double get levelProgress => xpToNext == 0 ? 0 : (xp / xpToNext).clamp(0, 1);

  /// إضافة نقاط (مع ترقية المستوى عند تجاوز العتبة).
  void addXp(int amount) {
    xp += amount;
    while (xp >= xpToNext) {
      xp -= xpToNext;
      level++;
      xpToNext += 100; // تصاعد بسيط
    }
    _emit();
  }

  /// زيادة تقدّم هدف معيّن.
  void bumpGoal(String id, {int by = 1}) {
    goals = [
      for (final g in goals)
        g.id == id ? g.copyWith(progress: g.progress + by) : g,
    ];
    _emit();
  }
}
