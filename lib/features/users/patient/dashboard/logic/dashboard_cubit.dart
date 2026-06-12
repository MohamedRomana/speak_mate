import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/logic/action_state.dart';
import '../../../../../core/networking/api_result.dart';
import '../data/models/dashboard_data.dart';
import '../data/repos/dashboard_repo.dart';

/// كيوبت لوحة المتدرّب — يحمّل حزمة بيانات اللوحة.
class DashboardCubit extends Cubit<ActionState> {
  final DashboardRepo _repo;
  DashboardCubit(this._repo) : super(const ActionState.idle());

  DashboardData? data;

  Future<void> load() async {
    emit(const ActionState.loading());
    final res = await _repo.getDashboard();
    if (isClosed) return;
    if (res is Failure<DashboardData>) {
      emit(ActionState.error(res.error.message ?? ''));
      return;
    }
    data = (res as Success<DashboardData>).data;
    emit(const ActionState.success());
  }
}
