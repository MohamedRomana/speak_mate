import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../generated/locale_keys.g.dart';

/// نوع خطوة الجلسة.
enum SessionStepKind { repeat, tip }

/// خطوة واحدة في الجلسة الموجّهة.
class SessionStep {
  final SessionStepKind kind;
  final String word; // الكلمة المطلوب تكرارها (لـ repeat)
  final String emoji;
  final String tipKey; // مفتاح نص النصيحة (لـ tip)

  const SessionStep({
    this.kind = SessionStepKind.repeat,
    this.word = '',
    this.emoji = '',
    this.tipKey = '',
  });
}

/// مرحلة الجلسة العامة.
enum SessionPhase { connecting, intro, active, recording, finished }

/// كيوبت الجلسة الموجّهة المباشرة (mock). الحالة عدّاد إصدار، والبيانات في الحقول.
class SessionCubit extends Cubit<int> {
  SessionCubit() : super(0);

  SessionPhase phase = SessionPhase.connecting;
  int index = 0;
  int elapsedSeconds = 0;
  int completedSteps = 0;
  Timer? _timer;

  final List<SessionStep> steps = const [
    SessionStep(word: 'شَمس', emoji: '🌞'),
    SessionStep(word: 'قَمَر', emoji: '🌙'),
    SessionStep(kind: SessionStepKind.tip, tipKey: LocaleKeys.tipBreathe),
    SessionStep(word: 'سَمَكة', emoji: '🐟'),
    SessionStep(word: 'وَردة', emoji: '🌹'),
  ];

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  SessionStep get current => steps[index];
  bool get isLast => index >= steps.length - 1;
  double get progress => steps.isEmpty ? 0 : (index + 1) / steps.length;

  String get durationLabel {
    final m = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> start() async {
    phase = SessionPhase.connecting;
    _emit();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (isClosed) return;
    phase = SessionPhase.intro;
    _emit();
  }

  void beginActivities() {
    phase = SessionPhase.active;
    _startTimer();
    _emit();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds++;
      _emit();
    });
  }

  /// بدء تسجيل تكرار الكلمة (mock) ثم الانتقال للخطوة التالية.
  Future<void> recordStep() async {
    if (phase == SessionPhase.recording) return;
    phase = SessionPhase.recording;
    _emit();
    await Future.delayed(const Duration(milliseconds: 1400));
    if (isClosed) return;
    completedSteps++;
    phase = SessionPhase.active;
    _advance();
  }

  /// إنهاء خطوة نصيحة والمتابعة.
  void continueTip() {
    completedSteps++;
    _advance();
  }

  void _advance() {
    if (isLast) {
      phase = SessionPhase.finished;
      _timer?.cancel();
      _emit();
      return;
    }
    index++;
    phase = SessionPhase.active;
    _emit();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
