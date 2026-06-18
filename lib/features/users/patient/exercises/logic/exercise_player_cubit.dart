import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/cache/cache_helper.dart';
import '../../../../../core/networking/api_result.dart';
import '../../../../../core/services/speech_service.dart';
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
  final SpeechService _speech;
  final Random _rnd = Random();

  /// [presetItems] إن مُرِّرت تُستخدم مباشرةً (للألعاب) بدل التحميل بحسب الفئة.
  final List<ExerciseItem>? presetItems;

  ExercisePlayerCubit(
    this._repo, {
    required this.category,
    this.presetItems,
    SpeechService? speech,
  })  : _speech = speech ?? SpeechService(),
        super(0);

  PlayerPhase phase = PlayerPhase.loading;
  List<ExerciseItem> items = [];
  int index = 0;
  int lastStars = 0;
  int totalStars = 0;
  int? selectedOption;
  bool matchCorrect = false;

  // نتيجة تحليل النطق الحقيقي لتمرين التكرار.
  bool lastCorrect = true;
  String lastRecognized = '';
  bool _sttOn = false;

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
    if (presetItems != null) {
      items = presetItems!;
      _set(PlayerPhase.prompt);
      return;
    }
    _set(PlayerPhase.loading);
    final res =
        await _repo.getExercises(category, CacheHelper.getDifficultyType());
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

  /// يبدأ التسجيل + الاستماع الحقيقي (STT). لو غير متاح يرجع للمحاكاة.
  Future<void> startRecording() async {
    _set(PlayerPhase.recording);
    _sttOn = await _speech.start(localeId: 'ar_SA');
  }

  /// يوقف التسجيل ويحلّل النطق فعليًا: يقارن المنطوق بالكلمة المستهدفة.
  Future<void> stopRecording() async {
    _set(PlayerPhase.checking);
    if (_sttOn) {
      lastRecognized = await _speech.stop();
      if (isClosed) return;
      final r = SpeechMatch.ratio(lastRecognized, current.prompt);
      if (r >= 0.85) {
        lastStars = 3;
        lastCorrect = true;
      } else if (r >= 0.55) {
        lastStars = 2;
        lastCorrect = true;
      } else {
        lastStars = 0;
        lastCorrect = false;
      }
    } else {
      // محاكاة عند عدم توفّر الميكروفون/الخدمة.
      await Future.delayed(const Duration(milliseconds: 1100));
      if (isClosed) return;
      lastRecognized = '';
      lastStars = 2 + _rnd.nextInt(2);
      lastCorrect = true;
    }
    if (lastCorrect) totalStars += lastStars;
    _set(PlayerPhase.result);
  }

  /// إعادة محاولة تمرين التكرار الحالي (بعد نتيجة خاطئة).
  void retryCurrent() {
    lastCorrect = true;
    lastRecognized = '';
    lastStars = 0;
    _set(PlayerPhase.prompt);
  }

  /// اختيار صورة في تمرين المطابقة. يعمل دائماً (حتى بعد اختيار خاطئ سابق):
  /// الإجابة الخاطئة تُعرض ثوانٍ قصيرة ثم تُمسح تلقائياً ليُعيد المتدرّب المحاولة.
  void selectOption(int i) {
    if (matchCorrect) return; // مُقفل بعد الإجابة الصحيحة
    selectedOption = i;
    final correct = i == current.correctIndex;
    if (correct) {
      matchCorrect = true;
      lastStars = 3;
      totalStars += 3;
      _set(PlayerPhase.matchResult);
    } else {
      _set(PlayerPhase.matchResult);
      // مسح الاختيار الخاطئ تلقائياً للسماح بإعادة المحاولة بوضوح.
      Future.delayed(const Duration(milliseconds: 900), () {
        if (isClosed || matchCorrect) return;
        selectedOption = null;
        _set(PlayerPhase.prompt);
      });
    }
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
    lastCorrect = true;
    lastRecognized = '';
    _set(PlayerPhase.prompt);
  }

  @override
  Future<void> close() {
    _speech.cancel();
    return super.close();
  }
}
