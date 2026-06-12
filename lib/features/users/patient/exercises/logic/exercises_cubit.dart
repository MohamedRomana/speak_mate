import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/logic/action_state.dart';
import '../../../../../core/networking/api_result.dart';
import '../data/models/exercise_models.dart';
import '../data/repos/exercises_repo.dart';

/// كيوبت قائمة فئات التمارين.
class ExercisesCubit extends Cubit<ActionState> {
  final ExercisesRepo _repo;
  ExercisesCubit(this._repo) : super(const ActionState.idle());

  List<ExerciseCategoryInfo> categories = [];

  Future<void> load() async {
    emit(const ActionState.loading());
    final res = await _repo.getCategories();
    if (isClosed) return;
    if (res is Failure<List<ExerciseCategoryInfo>>) {
      emit(ActionState.error(res.error.message ?? ''));
      return;
    }
    categories = (res as Success<List<ExerciseCategoryInfo>>).data;
    emit(const ActionState.success());
  }
}
