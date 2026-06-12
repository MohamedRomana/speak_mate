import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/networking/api_error_model.dart';
import '../../../../../../core/networking/api_result.dart';
import '../models/exercise_models.dart';

/// مستودع التمارين — mock.
class ExercisesRepo {
  Future<ApiResult<List<ExerciseCategoryInfo>>> getCategories() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success([
          ExerciseCategoryInfo(
            category: ExerciseCategory.articulation,
            total: 12,
            completed: 7,
          ),
          ExerciseCategoryInfo(
            category: ExerciseCategory.vocabulary,
            total: 10,
            completed: 3,
          ),
          ExerciseCategoryInfo(
            category: ExerciseCategory.soundMatch,
            total: 8,
            completed: 5,
          ),
          ExerciseCategoryInfo(
            category: ExerciseCategory.tongueTwisters,
            total: 6,
            completed: 1,
          ),
        ]);
      }
      throw UnimplementedError('Real API not wired yet');
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  Future<ApiResult<List<ExerciseItem>>> getExercises(
    ExerciseCategory category,
  ) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        return ApiResult.success(_mockItems(category));
      }
      throw UnimplementedError('Real API not wired yet');
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  List<ExerciseItem> _mockItems(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.articulation:
        return const [
          ExerciseItem(
            id: 'a1',
            kind: ExerciseKind.repeat,
            prompt: 'رَمّان',
            emoji: '🍎',
            difficulty: ExerciseDifficulty.easy,
          ),
          ExerciseItem(
            id: 'a2',
            kind: ExerciseKind.repeat,
            prompt: 'سَمَكة',
            emoji: '🐟',
            difficulty: ExerciseDifficulty.easy,
          ),
          ExerciseItem(
            id: 'a3',
            kind: ExerciseKind.repeat,
            prompt: 'شَمس',
            emoji: '☀️',
            difficulty: ExerciseDifficulty.medium,
          ),
        ];
      case ExerciseCategory.vocabulary:
        return const [
          ExerciseItem(
            id: 'v1',
            kind: ExerciseKind.repeat,
            prompt: 'سيّارة',
            emoji: '🚗',
            difficulty: ExerciseDifficulty.easy,
          ),
          ExerciseItem(
            id: 'v2',
            kind: ExerciseKind.repeat,
            prompt: 'طائرة',
            emoji: '✈️',
            difficulty: ExerciseDifficulty.medium,
          ),
        ];
      case ExerciseCategory.soundMatch:
        return const [
          ExerciseItem(
            id: 'm1',
            kind: ExerciseKind.match,
            prompt: 'قِطّة',
            emoji: '🔊',
            difficulty: ExerciseDifficulty.easy,
            options: ['🐱', '🐶', '🐰', '🐻'],
            correctIndex: 0,
          ),
          ExerciseItem(
            id: 'm2',
            kind: ExerciseKind.match,
            prompt: 'تُفّاحة',
            emoji: '🔊',
            difficulty: ExerciseDifficulty.easy,
            options: ['🍌', '🍎', '🍇', '🍊'],
            correctIndex: 1,
          ),
          ExerciseItem(
            id: 'm3',
            kind: ExerciseKind.match,
            prompt: 'شَمس',
            emoji: '🔊',
            difficulty: ExerciseDifficulty.medium,
            options: ['🌙', '⭐', '☀️', '☁️'],
            correctIndex: 2,
          ),
        ];
      case ExerciseCategory.tongueTwisters:
        return const [
          ExerciseItem(
            id: 't1',
            kind: ExerciseKind.repeat,
            prompt: 'خيط حرير على حيط خليل',
            emoji: '🧵',
            difficulty: ExerciseDifficulty.hard,
          ),
          ExerciseItem(
            id: 't2',
            kind: ExerciseKind.repeat,
            prompt: 'شرشف شرشفنا ما تشرشف',
            emoji: '🛏️',
            difficulty: ExerciseDifficulty.hard,
          ),
        ];
    }
  }
}
