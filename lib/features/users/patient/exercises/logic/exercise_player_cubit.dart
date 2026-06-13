import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/networking/api_result.dart';
import '../data/models/exercise_models.dart';
import '../data/repos/exercises_repo.dart';

/// مراحل مشغّل التمرين.
enum PlayerPhase {
  loading,
  prompt, // عرض الكلمة بانتظار الاستماع/التسجيل
  listening, // تشغيل النطق الصحيح (محاكاة TTS)
  recording, // المستخدم يسجّل صوته
  checking, // تحليل (محاكاة)
  result, // نتيجة تمرين التكرار (نجوم)
  matchResult, // نتيجة تمرين المطابقة (صح/خطأ)
  finished, // اكتملت كل التمارين
  error,
}

/// كيوبت مشغّل جلسة تمارين فئة واحدة.
///
/// الحالة المُصدَرة مجرّد عدّاد إصدار (int) يتزايد عند كل تغيير، والمرحلة الفعلية
/// في الحقل [phase]. هذا يضمن إعادة بناء الواجهة حتى عند تكرار نفس المرحلة
/// (مثلاً اختيار خاطئ ثم اختيار صحيح في المطابقة).
class ExercisePlayerCubit extends Cubit<int> {
  final ExercisesRepo _repo;
  final ExerciseCategory category;
  final Random _rnd = Random();

  ExercisePlayerCubit(this._repo, {required this.category}) : super(0);

  PlayerPhase phase = PlayerPhase.loading;
  List<ExerciseItem> items = [];
  int index = 0;
  int lastStars = 0;
  int totalStars = 0;
  int? selectedOption;
  bool matchCorrect = false;

  int _rev = 0;
  void _set(PlayerPhase p) {
    phase = p;
    if (!isClosed) emit(++_rev);
  }

  ExerciseItem get current => items[index];
  bool get isLast => index >= items.length - 1;
  int get maxStars => items.length * 3;
  double get progress => items.isEmpty ? 0 : (index + 1) / items.length;

  Future<void> load() async {
    _set(PlayerPhase.loading);
    final res = await _repo.getExercises(category);
    if (isClosed) return;
    if (res is Failure<List<ExerciseItem>>) {
      _set(PlayerPhase.error);
      return;
    }
    items = (res as Success<List<ExerciseItem>>).data;
    _set(PlayerPhase.prompt);
  }

  /// محاكاة تشغيل النطق الصحيح.
  Future<void> listen() async {
    if (phase == PlayerPhase.recording || phase == PlayerPhase.checking) return;
    final resume = phase; // نرجع للمرحلة الحالية بعد الاستماع (prompt/matchResult)
    _set(PlayerPhase.listening);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (isClosed) return;
    _set(resume == PlayerPhase.listening ? PlayerPhase.prompt : resume);
  }

  void startRecording() => _set(PlayerPhase.recording);

  /// إيقاف التسجيل ثم محاكاة التحليل وإعطاء نتيجة (2..3 نجوم تشجيعية).
  Future<void> stopRecording() async {
    _set(PlayerPhase.checking);
    await Future.delayed(const Duration(milliseconds: 1300));
    if (isClosed) return;
    lastStars = 2 + _rnd.nextInt(2);
    totalStars += lastStars;
    _set(PlayerPhase.result);
  }

  /// اختيار صورة في تمرين المطابقة. يعمل دائماً (حتى بعد اختيار خاطئ سابق).
  void selectOption(int i) {
    if (matchCorrect) return; // مُقفل بعد الإجابة الصحيحة
    selectedOption = i;
    final correct = i == current.correctIndex;
    if (correct) {
      matchCorrect = true;
      lastStars = 3;
      totalStars += 3;
    }
    _set(PlayerPhase.matchResult);
  }

  void next() {
    if (isLast) {
      _set(PlayerPhase.finished);
      return;
    }
    index++;
    selectedOption = null;
    matchCorrect = false;
    lastStars = 0;
    _set(PlayerPhase.prompt);
  }

  /// إعادة الجلسة من البداية.
  void restart() {
    index = 0;
    totalStars = 0;
    lastStars = 0;
    selectedOption = null;
    matchCorrect = false;
    _set(PlayerPhase.prompt);
  }
}
