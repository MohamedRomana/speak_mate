import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/logic/action_state.dart';
import '../../../core/networking/api_result.dart';
import '../data/models/clinic_models.dart';
import '../data/repos/clinic_repo.dart';

/// كيوبت لوحة العيادة — يحمّل الإحصائيات والمواعيد والفواتير.
class ClinicHomeCubit extends Cubit<ActionState> {
  final ClinicRepo _repo;
  ClinicHomeCubit(this._repo) : super(const ActionState.idle());

  List<ClinicAppointment> appointments = [];
  ClinicStats get stats => _repo.stats;
  List<Invoice> get invoices => _repo.invoices;

  Future<void> load() async {
    emit(const ActionState.loading());
    final res = await _repo.getAppointments();
    if (isClosed) return;
    if (res is Failure<List<ClinicAppointment>>) {
      emit(ActionState.error(res.error.message ?? ''));
      return;
    }
    appointments = (res as Success<List<ClinicAppointment>>).data;
    emit(const ActionState.success());
  }
}
