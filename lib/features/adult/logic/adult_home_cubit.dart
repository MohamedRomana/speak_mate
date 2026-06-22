import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/logic/action_state.dart';
import '../../../core/networking/api_result.dart';
import '../../users/patient/dashboard/data/models/session_model.dart';
import '../data/models/rehab_models.dart';
import '../data/repos/adult_repo.dart';

/// كيوبت لوحة الكبار — يحمّل وحدات إعادة التأهيل والجلسات والإحصائيات.
class AdultHomeCubit extends Cubit<ActionState> {
  final AdultRepo _repo;
  AdultHomeCubit(this._repo) : super(const ActionState.idle());

  List<RehabModule> modules = [];
  List<SessionModel> sessions = [];
  int get recoveryProgress => _repo.recoveryProgress;
  int get avgAccuracy => _repo.avgAccuracy;
  int get weeklySessions => _repo.weeklySessions;

  List<SessionModel> get upcoming =>
      sessions.where((s) => s.status == SessionStatus.upcoming).toList();
  List<SessionModel> get completed =>
      sessions.where((s) => s.status == SessionStatus.completed).toList();

  Future<void> load() async {
    emit(const ActionState.loading());
    final res = await _repo.getModules();
    if (isClosed) return;
    if (res is Failure<List<RehabModule>>) {
      emit(ActionState.error(res.error.message ?? ''));
      return;
    }
    modules = (res as Success<List<RehabModule>>).data;
    final sRes = await _repo.getSessions();
    if (isClosed) return;
    if (sRes is Success<List<SessionModel>>) {
      sessions = sRes.data;
    }
    emit(const ActionState.success());
  }
}
