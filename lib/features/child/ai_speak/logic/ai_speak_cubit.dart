import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependancy_injection.dart';
import '../../../../core/services/phoneme_analyzer.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/services/weak_sounds_tracker.dart';

enum AiSpeakPhase { prompt, recording, checking, result }

class SpeakWord {
  final String text;
  final String emoji;
  const SpeakWord(this.text, this.emoji);
}

/// كيوبت "تحدّث مع AI": مايك → نطق → تحليل فوري حقيقي (STT) → تصحيح + درجة.
class AiSpeakCubit extends Cubit<int> {
  final SpeechService _speech;
  AiSpeakCubit({SpeechService? speech}) : _speech = speech ?? SpeechService(), super(0);

  static const _words = [
    SpeakWord('شَمس', '🌞'),
    SpeakWord('قَمَر', '🌙'),
    SpeakWord('سَمَكة', '🐟'),
    SpeakWord('وَردة', '🌹'),
    SpeakWord('بطة', '🦆'),
    SpeakWord('تُفّاحة', '🍎'),
    SpeakWord('قِطّة', '🐱'),
    SpeakWord('سيّارة', '🚗'),
  ];

  AiSpeakPhase phase = AiSpeakPhase.prompt;
  int index = 0;
  int score = 0;
  bool correct = false;
  String recognized = '';
  String focus = '';
  SpeechAnalysis? analysis;
  bool _sttOn = false;

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  SpeakWord get current => _words[index];

  Future<void> startRecording() async {
    phase = AiSpeakPhase.recording;
    _emit();
    _sttOn = await _speech.start(localeId: 'ar_SA');
  }

  Future<void> stopRecording() async {
    phase = AiSpeakPhase.checking;
    _emit();
    if (_sttOn) {
      recognized = await _speech.stop();
      if (isClosed) return;
    } else {
      // محاكاة عند غياب الميكروفون: نطق شبه-صحيح يُغذّي نفس محرّك التحليل.
      await Future.delayed(const Duration(milliseconds: 1100));
      if (isClosed) return;
      recognized = _mockRecognized();
    }
    // تحليل فونيمي كامل (محاذاة + كشف أخطاء + درجة موزونة + فونيم التركيز).
    final a = PhonemeAnalyzer.analyze(recognized, current.text);
    analysis = a;
    getIt<WeakSoundsTracker>().record(a);
    score = a.score;
    correct = a.isCorrect;
    focus = a.focusLabel;
    phase = AiSpeakPhase.result;
    _emit();
  }

  /// نطق محاكى: غالبًا صحيح، وأحيانًا يُبدِل أول صوت صعب ليُظهر التحليل الفونيمي.
  String _mockRecognized() {
    final t = current.text;
    if (index % 3 == 1) {
      final norm = SpeechMatch.normalize(t).replaceAll(' ', '');
      // أبدِل أول حرف "ر/ل/س" بحرف قريب لإظهار كشف الخطأ.
      const swaps = {'ر': 'غ', 'ل': 'ر', 'س': 'ث', 'ث': 'س', 'ش': 'س'};
      for (final entry in swaps.entries) {
        final i = norm.indexOf(entry.key);
        if (i >= 0) {
          return norm.replaceRange(i, i + 1, entry.value);
        }
      }
    }
    return t;
  }

  void retry() {
    phase = AiSpeakPhase.prompt;
    recognized = '';
    analysis = null;
    _emit();
  }

  void next() {
    index = (index + 1) % _words.length;
    phase = AiSpeakPhase.prompt;
    recognized = '';
    score = 0;
    correct = false;
    analysis = null;
    _emit();
  }

  @override
  Future<void> close() {
    _speech.cancel();
    return super.close();
  }
}
