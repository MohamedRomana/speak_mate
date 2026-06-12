import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/logic/action_state.dart';
import '../../../../../core/networking/api_result.dart';
import '../data/models/report_data.dart';
import '../data/repos/reports_repo.dart';

/// كيوبت تقارير التقدّم — يحمّل تقرير الفترة المختارة.
class ReportsCubit extends Cubit<ActionState> {
  final ReportsRepo _repo;
  final String lang;
  ReportsCubit(this._repo, {required this.lang})
      : super(const ActionState.idle());

  ReportData? data;
  ReportPeriod period = ReportPeriod.week;

  Future<void> load() async {
    emit(const ActionState.loading());
    final res = await _repo.getReport(period, lang);
    if (isClosed) return;
    if (res is Failure<ReportData>) {
      emit(ActionState.error(res.error.message ?? ''));
      return;
    }
    data = (res as Success<ReportData>).data;
    emit(const ActionState.success());
  }

  void switchPeriod(ReportPeriod p) {
    if (p == period) return;
    period = p;
    load();
  }
}
