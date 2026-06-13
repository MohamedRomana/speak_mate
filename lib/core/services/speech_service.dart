// ignore_for_file: deprecated_member_use

import 'package:speech_to_text/speech_to_text.dart';

/// خدمة تحويل الكلام إلى نص (تحليل النطق الحقيقي). تُستخدم في تمارين التكرار
/// لمقارنة ما نطقه المتدرّب بالكلمة المستهدفة.
class SpeechService {
  final SpeechToText _stt = SpeechToText();
  bool _available = false;
  String _lastWords = '';

  bool get isAvailable => _available;
  String get lastWords => _lastWords;

  Future<bool> ensureInit() async {
    if (_available) return true;
    try {
      _available = await _stt.initialize(
        onError: (_) {},
        onStatus: (_) {},
      );
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  /// يبدأ الاستماع. يرجّع false لو الميكروفون/الخدمة غير متاحة (نرجع للمحاكاة).
  Future<bool> start({String localeId = 'ar_SA'}) async {
    final ok = await ensureInit();
    if (!ok) return false;
    _lastWords = '';
    try {
      await _stt.listen(
        localeId: localeId,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        onResult: (r) => _lastWords = r.recognizedWords,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// يوقف الاستماع ويرجّع النص المُتعرَّف عليه.
  Future<String> stop() async {
    try {
      await _stt.stop();
    } catch (_) {}
    // مهلة قصيرة لاستلام النتيجة النهائية.
    await Future.delayed(const Duration(milliseconds: 350));
    return _lastWords;
  }

  Future<void> cancel() async {
    try {
      await _stt.cancel();
    } catch (_) {}
  }
}

/// أدوات مقارنة النطق العربي (تطبيع + نسبة تشابه).
class SpeechMatch {
  SpeechMatch._();

  /// تطبيع نص عربي: إزالة التشكيل والتطويل وتوحيد الألف/التاء المربوطة.
  static String normalize(String input) {
    var s = input.trim();
    // إزالة التشكيل والتطويل.
    s = s.replaceAll(RegExp('[ً-ْٰـ]'), '');
    // توحيد الألفات والهمزات.
    s = s.replaceAll(RegExp('[آأإٱ]'), 'ا');
    s = s.replaceAll('ة', 'ه'); // ة → ه
    s = s.replaceAll('ى', 'ي'); // ى → ي
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.toLowerCase();
  }

  /// نسبة تشابه (0..1) بين النص المُتعرَّف والكلمة الهدف.
  static double ratio(String recognized, String target) {
    final r = normalize(recognized);
    final t = normalize(target);
    if (t.isEmpty) return 0;
    if (r.isEmpty) return 0;
    // لو احتوى المنطوق على الكلمة الهدف (أو العكس) → تطابق عالٍ.
    if (r.contains(t) || t.contains(r)) return 1.0;
    // وإلا نسبة تشابه على مستوى الحروف عبر مسافة Levenshtein.
    final dist = _levenshtein(r, t);
    final maxLen = r.length > t.length ? r.length : t.length;
    return (1 - dist / maxLen).clamp(0.0, 1.0);
  }

  static int _levenshtein(String a, String b) {
    final m = a.length, n = b.length;
    if (m == 0) return n;
    if (n == 0) return m;
    final prev = List<int>.generate(n + 1, (i) => i);
    final curr = List<int>.filled(n + 1, 0);
    for (var i = 1; i <= m; i++) {
      curr[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [
          curr[j - 1] + 1,
          prev[j] + 1,
          prev[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
      for (var j = 0; j <= n; j++) {
        prev[j] = curr[j];
      }
    }
    return prev[n];
  }
}
