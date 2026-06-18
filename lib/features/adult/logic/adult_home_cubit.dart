import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/logic/action_state.dart';
import '../../../core/networking/api_result.dart';
import '../data/models/rehab_models.dart';
import '../data/repos/adult_repo.dart';

/// كيوبت لوحة الكبار — يحمّل وحدات إعادة التأهيل والإحصائيات.
class AdultHomeCubit extends Cubit<ActionState> {
  final AdultRepo _repo;
  AdultHomeCubit(this._repo) : super(const ActionState.idle());

  List<RehabModule> modules = [];
  int get recoveryProgress => _repo.recoveryProgress;
  int get avgAccuracy => _repo.avgAccuracy;
  int get weeklySessions => _repo.weeklySessions;

  Future<void> load() async {
    emit(const ActionState.loading());
    final res = await _repo.getModules();
    if (isClosed) return;
    if (res is Failure<List<RehabModule>>) {
      emit(ActionState.error(res.error.message ?? ''));
      return;
    }
    modules = (res as Success<List<RehabModule>>).data;
    emit(const ActionState.success());
  }
}
