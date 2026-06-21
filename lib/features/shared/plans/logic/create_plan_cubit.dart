import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../data/models/therapy_plan.dart';
import '../data/repos/plans_repo.dart';

/// كيوبت إنشاء خطة مخصّصة (جانب الأخصائي). يحمل حالة النموذج ويبني [TherapyPlan]
/// عند الحفظ. الحالة عدّاد إصدار والبيانات في الحقول.
class CreatePlanCubit extends Cubit<int> {
  final PlansRepo _repo;
  CreatePlanCubit(this._repo) : super(0);

  /// لوحة أصوات عربية شائعة للاختيار كأهداف.
  static const soundPalette = [
    'ر', 'ل', 'س', 'ث', 'ص', 'ش', 'ز', 'ذ', 'ظ', 'ض', 'ط', 'ق', 'غ', 'ج', 'ك'
  ];

  /// أهداف أسبوعية جاهزة للتفعيل (مع عدد افتراضي قابل للتعديل).
  static const presetTargets = [
    ('تمارين تكرار', '🔁', 12),
    ('مطابقة أصوات', '🎯', 8),
    ('ألعاب نطق', '🎮', 10),
    ('جلسات مع الأخصائي', '👩‍⚕️', 4),
    ('تسمية صور', '🖼️', 15),
  ];

  String title = '';
  String goal = '';
  final Set<String> sounds = {};
  final Set<int> targetIdx = {0, 1}; // أول هدفين مفعّلان افتراضيًا
  int durationWeeks = 4;
  int sessionsPerWeek = 3;
  bool saving = false;
  String? errorMsg;

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  bool get isValid => title.trim().isNotEmpty && targetIdx.isNotEmpty;

  void setTitle(String v) {
    title = v;
    _emit();
  }

  void setGoal(String v) {
    goal = v;
    _emit();
  }

  void toggleSound(String s) {
    sounds.contains(s) ? sounds.remove(s) : sounds.add(s);
    _emit();
  }

  void toggleTarget(int i) {
    targetIdx.contains(i) ? targetIdx.remove(i) : targetIdx.add(i);
    _emit();
  }

  void setDuration(int w) {
    durationWeeks = w.clamp(1, 24);
    _emit();
  }

  void setSessions(int s) {
    sessionsPerWeek = s.clamp(1, 7);
    _emit();
  }

  TherapyPlan _draft() => TherapyPlan(
        id: '',
        title: title.trim(),
        goal: goal.trim(),
        targetSounds: sounds.toList(),
        durationWeeks: durationWeeks,
        sessionsPerWeek: sessionsPerWeek,
        targets: [
          for (final i in targetIdx)
            PlanTarget(
              titleKey: presetTargets[i].$1,
              emoji: presetTargets[i].$2,
              targetCount: presetTargets[i].$3,
            ),
        ],
      );

  /// يحفظ الخطة ويرجّعها عند النجاح (أو null عند الفشل).
  Future<TherapyPlan?> save() async {
    if (!isValid) return null;
    saving = true;
    _emit();
    final res = await _repo.createPlan(_draft());
    saving = false;
    if (isClosed) return null;
    if (res is Success<TherapyPlan>) {
      _emit();
      return res.data;
    }
    errorMsg = (res as Failure<TherapyPlan>).error.message;
    _emit();
    return null;
  }
}
