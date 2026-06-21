import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../data/models/therapy_plan.dart';
import '../data/repos/plans_repo.dart';

enum AssignPhase { loading, ready, error, assigning, assigned }

/// كيوبت إسناد خطة لمريض (جانب الأخصائي). الحالة عدّاد إصدار والبيانات في الحقول.
class AssignPlanCubit extends Cubit<int> {
  final PlansRepo _repo;
  final String patientId;
  AssignPlanCubit(this._repo, {required this.patientId}) : super(0);

  AssignPhase phase = AssignPhase.loading;
  List<TherapyPlan> templates = [];
  String? selectedId;
  String? errorMsg;

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  TherapyPlan? get selected =>
      templates.where((p) => p.id == selectedId).cast<TherapyPlan?>().firstOrNull;

  Future<void> load() async {
    phase = AssignPhase.loading;
    _emit();
    final res = await _repo.getTemplates();
    if (isClosed) return;
    if (res is Success<List<TherapyPlan>>) {
      templates = res.data;
      selectedId = templates.isNotEmpty ? templates.first.id : null;
      phase = AssignPhase.ready;
    } else {
      errorMsg = (res as Failure<List<TherapyPlan>>).error.message;
      phase = AssignPhase.error;
    }
    _emit();
  }

  void select(String id) {
    selectedId = id;
    _emit();
  }

  /// يضيف خطة أنشأها الأخصائي للقائمة ويحدّدها (بعد العودة من شاشة الإنشاء).
  void addTemplate(TherapyPlan plan) {
    templates = [plan, ...templates];
    selectedId = plan.id;
    _emit();
  }

  Future<bool> assign() async {
    if (selectedId == null) return false;
    phase = AssignPhase.assigning;
    _emit();
    final res = await _repo.assignPlan(patientId: patientId, planId: selectedId!);
    if (isClosed) return false;
    if (res is Success<bool>) {
      phase = AssignPhase.assigned;
      _emit();
      return true;
    }
    errorMsg = (res as Failure<bool>).error.message;
    phase = AssignPhase.ready;
    _emit();
    return false;
  }
}
