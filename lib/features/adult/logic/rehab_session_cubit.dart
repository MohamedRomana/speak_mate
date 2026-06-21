import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/dependancy_injection.dart';
import '../../../core/services/phoneme_analyzer.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/services/weak_sounds_tracker.dart';
import '../data/models/rehab_models.dart';
import '../data/repos/adult_repo.dart';

enum RehabPhase { prompt, listening, recording, checking, result, finished }

/// كيوبت جلسة إعادة التأهيل — يدعم الكلام البطيء (استماع) وتمارين الذاكرة (إخفاء)
/// وتحليل النطق الحقيقي بالـ STT. الحالة عدّاد إصدار والبيانات في الحقول.
class RehabSessionCubit extends Cubit<int> {
  final AdultRepo _repo;
  final RehabModule module;
  final SpeechService _speech;

  RehabSessionCubit(this._repo, {required this.module, SpeechService? speech})
      : _speech = speech ?? SpeechService(),
        super(0);

  late final List<RehabPhrase> phrases = _repo.phrases(module.type);
  RehabPhase phase = RehabPhase.prompt;
  int index = 0;
  int score = 0;
  bool correct = false;
  String recognized = '';
  int totalScore = 0;
  bool revealed = true; // تُخفى الكلمة في تمارين الذاكرة
  SpeechAnalysis? analysis;
  bool _sttOn = false;
  Timer? _hideTimer;

  final WeakSoundsTracker _weak = getIt<WeakSoundsTracker>();

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  RehabPhrase get current => phrases[index];
  bool get isLast => index >= phrases.length - 1;
  double get progress => phrases.isEmpty ? 0 : (index + 1) / phrases.length;
  int get maxScore => phrases.length * 100;

  void start() {
    _prepareCurrent();
  }

  void _prepareCurrent() {
    phase = RehabPhase.prompt;
    if (module.isMemory) {
      revealed = true;
      _emit();
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 3), () {
        revealed = false;
        _emit();
      });
    } else {
      revealed = true;
      _emit();
    }
  }

  /// محاكاة تشغيل بطيء وواضح للعبارة (للكلام البطيء).
  Future<void> listenSlow() async {
    if (phase == RehabPhase.recording || phase == RehabPhase.checking) return;
    phase = RehabPhase.listening;
    _emit();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (isClosed) return;
    phase = RehabPhase.prompt;
    _emit();
  }

  Future<void> startRecording() async {
    phase = RehabPhase.recording;
    _emit();
    _sttOn = await _speech.start(localeId: 'ar_SA');
  }

  Future<void> stopRecording() async {
    phase = RehabPhase.checking;
    _emit();
    if (_sttOn) {
      recognized = await _speech.stop();
      if (isClosed) return;
    } else {
      await Future.delayed(const Duration(milliseconds: 1100));
      if (isClosed) return;
      recognized = current.text; // محاكاة: نطق صحيح يغذّي المحرّك
    }
    // تحليل فونيمي موحّد + تغذية خريطة الأصوات الضعيفة.
    final a = PhonemeAnalyzer.analyze(recognized, current.text);
    analysis = a;
    _weak.record(a);
    score = a.score;
    correct = score >= 65;
    if (correct) totalScore += score;
    phase = RehabPhase.result;
    _emit();
  }

  void retry() {
    recognized = '';
    score = 0;
    correct = false;
    analysis = null;
    phase = RehabPhase.prompt;
    _emit();
  }

  void next() {
    if (isLast) {
      phase = RehabPhase.finished;
      _emit();
      return;
    }
    index++;
    recognized = '';
    score = 0;
    correct = false;
    analysis = null;
    _prepareCurrent();
  }

  void restart() {
    index = 0;
    totalScore = 0;
    recognized = '';
    score = 0;
    correct = false;
    analysis = null;
    _prepareCurrent();
  }

  @override
  Future<void> close() {
    _hideTimer?.cancel();
    _speech.cancel();
    return super.close();
  }
}
