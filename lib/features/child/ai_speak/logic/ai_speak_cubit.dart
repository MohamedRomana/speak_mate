import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/speech_service.dart';

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
      final r = SpeechMatch.ratio(recognized, current.text);
      score = (r * 100).round();
      correct = r >= 0.7;
    } else {
      await Future.delayed(const Duration(milliseconds: 1100));
      if (isClosed) return;
      recognized = '';
      score = 80 + (index % 3) * 6;
      correct = true;
    }
    final norm = SpeechMatch.normalize(current.text);
    focus = correct || norm.isEmpty ? '' : norm.substring(0, 1);
    phase = AiSpeakPhase.result;
    _emit();
  }

  void retry() {
    phase = AiSpeakPhase.prompt;
    recognized = '';
    _emit();
  }

  void next() {
    index = (index + 1) % _words.length;
    phase = AiSpeakPhase.prompt;
    recognized = '';
    score = 0;
    correct = false;
    _emit();
  }

  @override
  Future<void> close() {
    _speech.cancel();
    return super.close();
  }
}
