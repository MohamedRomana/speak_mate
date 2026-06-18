/// فئة التمرين.
enum ExerciseCategory { articulation, vocabulary, soundMatch, tongueTwisters }

/// مستوى الصعوبة (يتكيّف مع تقدّم المتدرّب).
enum ExerciseDifficulty { easy, medium, hard }

/// نوع التمرين:
/// - repeat: استماع + تسجيل (كرّر بعدي).
/// - match: مطابقة الكلمة المعروضة بالصورة.
/// - guess: استماع ثم تخمين الصورة (الكلمة مخفيّة).
/// - pictureName: تسمية الصورة بالنطق (الكلمة مخفيّة، تحليل STT).
enum ExerciseKind { repeat, match, guess, pictureName }

/// عنصر تمرين واحد.
class ExerciseItem {
  final String id;
  final ExerciseKind kind;

  /// النص المطلوب نطقه (للتكرار) أو الكلمة الهدف (للمطابقة).
  final String prompt;

  /// رمز تعبيري يمثّل الكلمة بصريًا.
  final String emoji;
  final ExerciseDifficulty difficulty;

  /// خيارات المطابقة (رموز تعبيرية) — فارغة لتمارين التكرار.
  final List<String> options;

  /// مؤشّر الخيار الصحيح في [options] (لتمارين المطابقة).
  final int correctIndex;

  const ExerciseItem({
    required this.id,
    required this.kind,
    required this.prompt,
    required this.emoji,
    required this.difficulty,
    this.options = const [],
    this.correctIndex = 0,
  });

  /// هل تُعرض الكلمة الهدف نصيًا؟ (تُخفى في الحزر/تسمية الصورة).
  bool get showsWord => kind == ExerciseKind.repeat || kind == ExerciseKind.match;

  /// تمارين الاختيار من الخيارات (مطابقة/حزر).
  bool get isMatchLike =>
      kind == ExerciseKind.match || kind == ExerciseKind.guess;

  /// تمارين التسجيل بالصوت (تكرار/تسمية صورة).
  bool get isRepeatLike =>
      kind == ExerciseKind.repeat || kind == ExerciseKind.pictureName;
}

/// أنواع ألعاب الطفل.
enum GameType { repeatAi, speakMatch, soundGuess, pictureNaming }

/// ملخّص فئة تمارين (للعرض في تبويب التمارين).
class ExerciseCategoryInfo {
  final ExerciseCategory category;
  final int total;
  final int completed;

  const ExerciseCategoryInfo({
    required this.category,
    required this.total,
    required this.completed,
  });

  double get progress => total == 0 ? 0 : completed / total;
}
