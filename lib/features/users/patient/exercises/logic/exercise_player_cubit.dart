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

/// كيوبت مشغّل جلسة تمارين فئة واحدة. البيانات في fields والـ state مجرّد مرحلة.
class ExercisePlayerCubit extends Cubit<PlayerPhase> {
  final ExercisesRepo _repo;
  final ExerciseCategory category;
  final Random _rnd = Random();

  ExercisePlayerCubit(this._repo, {required this.category})
      : super(PlayerPhase.loading);

  List<ExerciseItem> items = [];
  int index = 0;
  int lastStars = 0;
  int totalStars = 0;
  int? selectedOption;
  bool matchCorrect = false;

  ExerciseItem get current => items[index];
  bool get isLast => index >= items.length - 1;
  int get maxStars => items.length * 3;
  double get progress => items.isEmpty ? 0 : (index + 1) / items.length;

  Future<void> load() async {
    emit(PlayerPhase.loading);
    final res = await _repo.getExercises(category);
    if (isClosed) return;
    if (res is Failure<List<ExerciseItem>>) {
      emit(PlayerPhase.error);
      return;
    }
    items = (res as Success<List<ExerciseItem>>).data;
    emit(PlayerPhase.prompt);
  }

  /// محاكاة تشغيل النطق الصحيح.
  Future<void> listen() async {
    if (state == PlayerPhase.recording || state == PlayerPhase.checking) return;
    emit(PlayerPhase.listening);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (isClosed) return;
    emit(PlayerPhase.prompt);
  }

  void startRecording() => emit(PlayerPhase.recording);

  /// إيقاف التسجيل ثم محاكاة التحليل وإعطاء نتيجة (1..3 نجوم).
  Future<void> stopRecording() async {
    emit(PlayerPhase.checking);
    await Future.delayed(const Duration(milliseconds: 1300));
    if (isClosed) return;
    lastStars = 2 + _rnd.nextInt(2); // 2 أو 3 نجوم (تشجيعي)
    totalStars += lastStars;
    emit(PlayerPhase.result);
  }

  /// اختيار صورة في تمرين المطابقة.
  void selectOption(int i) {
    selectedOption = i;
    matchCorrect = i == current.correctIndex;
    if (matchCorrect) {
      lastStars = 3;
      totalStars += 3;
    }
    emit(PlayerPhase.matchResult);
  }

  /// إعادة محاولة التمرين الحالي (للمطابقة الخاطئة).
  void retry() {
    selectedOption = null;
    matchCorrect = false;
    emit(PlayerPhase.prompt);
  }

  void next() {
    if (isLast) {
      emit(PlayerPhase.finished);
      return;
    }
    index++;
    selectedOption = null;
    matchCorrect = false;
    lastStars = 0;
    emit(PlayerPhase.prompt);
  }

  /// إعادة الجلسة من البداية.
  void restart() {
    index = 0;
    totalStars = 0;
    lastStars = 0;
    selectedOption = null;
    matchCorrect = false;
    emit(PlayerPhase.prompt);
  }
}
