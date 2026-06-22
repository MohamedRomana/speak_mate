import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/networking/api_result.dart';
import '../data/models/clinic_models.dart';
import '../data/repos/clinic_repo.dart';

enum FinancePhase { loading, ready, error }

/// كيوبت التقرير المالي للعيادة. الحالة عدّاد إصدار.
class ClinicFinanceCubit extends Cubit<int> {
  final ClinicRepo _repo;
  ClinicFinanceCubit(this._repo) : super(0);

  FinancePhase phase = FinancePhase.loading;
  ClinicFinancials? data;
  String? errorMsg;

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  Future<void> load() async {
    phase = FinancePhase.loading;
    _emit();
    final res = await _repo.getFinancials();
    if (isClosed) return;
    if (res is Success<ClinicFinancials>) {
      data = res.data;
      phase = FinancePhase.ready;
    } else {
      errorMsg = (res as Failure<ClinicFinancials>).error.message;
      phase = FinancePhase.error;
    }
    _emit();
  }
}
