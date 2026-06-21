import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../data/models/therapy_plan.dart';
import '../data/repos/plans_repo.dart';

enum MyPlanPhase { loading, ready, empty, error }

/// كيوبت خطة المتدرّب الحالية. الحالة عدّاد إصدار والبيانات في الحقول.
class MyPlanCubit extends Cubit<int> {
  final PlansRepo _repo;
  MyPlanCubit(this._repo) : super(0);

  MyPlanPhase phase = MyPlanPhase.loading;
  TherapyPlan? plan;
  String? errorMsg;

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  Future<void> load() async {
    phase = MyPlanPhase.loading;
    _emit();
    final res = await _repo.getMyPlan();
    if (isClosed) return;
    if (res is Success<TherapyPlan?>) {
      plan = res.data;
      phase = plan == null ? MyPlanPhase.empty : MyPlanPhase.ready;
    } else {
      errorMsg = (res as Failure<TherapyPlan?>).error.message;
      phase = MyPlanPhase.error;
    }
    _emit();
  }
}
