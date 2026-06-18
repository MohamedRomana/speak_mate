import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/networking/api_error_model.dart';
import '../../../../../../core/networking/api_result.dart';
import '../models/exercise_models.dart';

/// مستودع التمارين — mock. التمارين والفئات تتكيّف مع **نوع صعوبة** المتدرّب:
/// النطق / السمع / المخارج، فلكل نوع مجموعة مناسبة ومختلفة.
class ExercisesRepo {
  Future<ApiResult<List<ExerciseCategoryInfo>>> getCategories(
    String difficulty,
  ) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return ApiResult.success(_categoriesFor(difficulty));
      }
      throw UnimplementedError('Real API not wired yet');
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  Future<ApiResult<List<ExerciseItem>>> getExercises(
    ExerciseCategory category,
    String difficulty,
  ) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        return ApiResult.success(_itemsFor(category, difficulty));
      }
      throw UnimplementedError('Real API not wired yet');
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// الفئات المناسبة لكل نوع صعوبة (مختلفة ومرتّبة حسب الأولوية).
  List<ExerciseCategoryInfo> _categoriesFor(String difficulty) {
    final List<ExerciseCategory> cats;
    switch (difficulty) {
      case 'difficultyHearing': // السمع: تمييز الأصوات والمفردات البصرية
        cats = const [
          ExerciseCategory.soundMatch,
          ExerciseCategory.vocabulary,
          ExerciseCategory.articulation,
        ];
        break;
      case 'difficultyArticulation': // المخارج: مخارج الحروف والألغاز اللفظية
        cats = const [
          ExerciseCategory.articulation,
          ExerciseCategory.tongueTwisters,
          ExerciseCategory.soundMatch,
        ];
        break;
      case 'difficultySpeech': // النطق: التكرار والمفردات والجمل
      default:
        cats = const [
          ExerciseCategory.articulation,
          ExerciseCategory.vocabulary,
          ExerciseCategory.tongueTwisters,
        ];
    }
    // أعداد إنجاز وهمية متفاوتة.
    const done = {0: 7, 1: 3, 2: 1};
    return [
      for (var i = 0; i < cats.length; i++)
        ExerciseCategoryInfo(
          category: cats[i],
          total: _itemsFor(cats[i], difficulty).length,
          completed: done[i] ?? 0,
        ),
    ];
  }

  /// عناصر لعبة محددة (تُمرَّر مباشرةً للمشغّل).
  List<ExerciseItem> gameItems(GameType game) {
    switch (game) {
      case GameType.repeatAi:
        return const [
          ExerciseItem(id: 'g_r1', kind: ExerciseKind.repeat, prompt: 'شَمس', emoji: '🌞', difficulty: ExerciseDifficulty.easy),
          ExerciseItem(id: 'g_r2', kind: ExerciseKind.repeat, prompt: 'قَمَر', emoji: '🌙', difficulty: ExerciseDifficulty.easy),
          ExerciseItem(id: 'g_r3', kind: ExerciseKind.repeat, prompt: 'وَردة', emoji: '🌹', difficulty: ExerciseDifficulty.medium),
        ];
      case GameType.speakMatch:
        return const [
          ExerciseItem(id: 'g_m1', kind: ExerciseKind.match, prompt: 'قِطّة', emoji: '🔊', difficulty: ExerciseDifficulty.easy, options: ['🐱', '🐶', '🐰', '🐻'], correctIndex: 0),
          ExerciseItem(id: 'g_m2', kind: ExerciseKind.match, prompt: 'تُفّاحة', emoji: '🔊', difficulty: ExerciseDifficulty.easy, options: ['🍌', '🍎', '🍇', '🍊'], correctIndex: 1),
          ExerciseItem(id: 'g_m3', kind: ExerciseKind.match, prompt: 'سيّارة', emoji: '🔊', difficulty: ExerciseDifficulty.medium, options: ['🚗', '🚲', '✈️', '🚂'], correctIndex: 0),
        ];
      case GameType.soundGuess:
        return const [
          ExerciseItem(id: 'g_s1', kind: ExerciseKind.guess, prompt: 'كلب', emoji: '🔊', difficulty: ExerciseDifficulty.easy, options: ['🐱', '🐶', '🐮', '🐸'], correctIndex: 1),
          ExerciseItem(id: 'g_s2', kind: ExerciseKind.guess, prompt: 'قطار', emoji: '🔊', difficulty: ExerciseDifficulty.medium, options: ['🚗', '🚂', '🚁', '⛵'], correctIndex: 1),
          ExerciseItem(id: 'g_s3', kind: ExerciseKind.guess, prompt: 'مطر', emoji: '🔊', difficulty: ExerciseDifficulty.medium, options: ['☀️', '🌧️', '❄️', '🌈'], correctIndex: 1),
        ];
      case GameType.pictureNaming:
        return const [
          ExerciseItem(id: 'g_p1', kind: ExerciseKind.pictureName, prompt: 'تُفّاحة', emoji: '🍎', difficulty: ExerciseDifficulty.easy),
          ExerciseItem(id: 'g_p2', kind: ExerciseKind.pictureName, prompt: 'سَمَكة', emoji: '🐟', difficulty: ExerciseDifficulty.easy),
          ExerciseItem(id: 'g_p3', kind: ExerciseKind.pictureName, prompt: 'سيّارة', emoji: '🚗', difficulty: ExerciseDifficulty.medium),
          ExerciseItem(id: 'g_p4', kind: ExerciseKind.pictureName, prompt: 'قَمَر', emoji: '🌙', difficulty: ExerciseDifficulty.medium),
        ];
    }
  }

  List<ExerciseItem> _itemsFor(ExerciseCategory category, String difficulty) {
    switch (category) {
      case ExerciseCategory.articulation:
        // كلمات مخارج تختلف بحسب نوع الصعوبة.
        if (difficulty == 'difficultyArticulation') {
          return const [
            ExerciseItem(id: 'art_a1', kind: ExerciseKind.repeat, prompt: 'قِطار', emoji: '🚂', difficulty: ExerciseDifficulty.medium),
            ExerciseItem(id: 'art_a2', kind: ExerciseKind.repeat, prompt: 'غُراب', emoji: '🐦‍⬛', difficulty: ExerciseDifficulty.hard),
            ExerciseItem(id: 'art_a3', kind: ExerciseKind.repeat, prompt: 'ثَعلَب', emoji: '🦊', difficulty: ExerciseDifficulty.hard),
            ExerciseItem(id: 'art_a4', kind: ExerciseKind.repeat, prompt: 'ضِفدَع', emoji: '🐸', difficulty: ExerciseDifficulty.hard),
          ];
        }
        if (difficulty == 'difficultyHearing') {
          return const [
            ExerciseItem(id: 'art_h1', kind: ExerciseKind.repeat, prompt: 'بابا', emoji: '👨', difficulty: ExerciseDifficulty.easy),
            ExerciseItem(id: 'art_h2', kind: ExerciseKind.repeat, prompt: 'ماما', emoji: '👩', difficulty: ExerciseDifficulty.easy),
            ExerciseItem(id: 'art_h3', kind: ExerciseKind.repeat, prompt: 'تُفّاحة', emoji: '🍎', difficulty: ExerciseDifficulty.medium),
          ];
        }
        return const [
          ExerciseItem(id: 'art_s1', kind: ExerciseKind.repeat, prompt: 'رَمّان', emoji: '🍎', difficulty: ExerciseDifficulty.easy),
          ExerciseItem(id: 'art_s2', kind: ExerciseKind.repeat, prompt: 'سَمَكة', emoji: '🐟', difficulty: ExerciseDifficulty.easy),
          ExerciseItem(id: 'art_s3', kind: ExerciseKind.repeat, prompt: 'شَمس', emoji: '☀️', difficulty: ExerciseDifficulty.medium),
          ExerciseItem(id: 'art_s4', kind: ExerciseKind.repeat, prompt: 'قَمَر', emoji: '🌙', difficulty: ExerciseDifficulty.medium),
        ];

      case ExerciseCategory.vocabulary:
        if (difficulty == 'difficultyHearing') {
          return const [
            ExerciseItem(id: 'voc_h1', kind: ExerciseKind.repeat, prompt: 'كلب', emoji: '🐶', difficulty: ExerciseDifficulty.easy),
            ExerciseItem(id: 'voc_h2', kind: ExerciseKind.repeat, prompt: 'قطة', emoji: '🐱', difficulty: ExerciseDifficulty.easy),
            ExerciseItem(id: 'voc_h3', kind: ExerciseKind.repeat, prompt: 'بيت', emoji: '🏠', difficulty: ExerciseDifficulty.easy),
          ];
        }
        return const [
          ExerciseItem(id: 'voc_s1', kind: ExerciseKind.repeat, prompt: 'سيّارة', emoji: '🚗', difficulty: ExerciseDifficulty.easy),
          ExerciseItem(id: 'voc_s2', kind: ExerciseKind.repeat, prompt: 'طائرة', emoji: '✈️', difficulty: ExerciseDifficulty.medium),
          ExerciseItem(id: 'voc_s3', kind: ExerciseKind.repeat, prompt: 'مدرسة', emoji: '🏫', difficulty: ExerciseDifficulty.medium),
        ];

      case ExerciseCategory.soundMatch:
        return const [
          ExerciseItem(id: 'm1', kind: ExerciseKind.match, prompt: 'قِطّة', emoji: '🔊', difficulty: ExerciseDifficulty.easy, options: ['🐱', '🐶', '🐰', '🐻'], correctIndex: 0),
          ExerciseItem(id: 'm2', kind: ExerciseKind.match, prompt: 'تُفّاحة', emoji: '🔊', difficulty: ExerciseDifficulty.easy, options: ['🍌', '🍎', '🍇', '🍊'], correctIndex: 1),
          ExerciseItem(id: 'm3', kind: ExerciseKind.match, prompt: 'شَمس', emoji: '🔊', difficulty: ExerciseDifficulty.medium, options: ['🌙', '⭐', '☀️', '☁️'], correctIndex: 2),
          ExerciseItem(id: 'm4', kind: ExerciseKind.match, prompt: 'سيّارة', emoji: '🔊', difficulty: ExerciseDifficulty.medium, options: ['🚗', '🚲', '✈️', '🚂'], correctIndex: 0),
        ];

      case ExerciseCategory.tongueTwisters:
        return const [
          ExerciseItem(id: 't1', kind: ExerciseKind.repeat, prompt: 'خيط حرير على حيط خليل', emoji: '🧵', difficulty: ExerciseDifficulty.hard),
          ExerciseItem(id: 't2', kind: ExerciseKind.repeat, prompt: 'شرشف شرشفنا ما تشرشف', emoji: '🛏️', difficulty: ExerciseDifficulty.hard),
          ExerciseItem(id: 't3', kind: ExerciseKind.repeat, prompt: 'قِدر مرقتنا قِدر مرقتكم', emoji: '🍲', difficulty: ExerciseDifficulty.hard),
        ];
    }
  }
}
