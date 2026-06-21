import 'phoneme_analyzer.dart';

/// متتبّع الأصوات الضعيفة عبر الجلسات (خريطة حرارية / weak-phoneme heatmap).
///
/// يجمّع نتائج محرّك الفونيمات من كل التمارين (طفل/بالغ/تحدّث مع AI) في عدّادات
/// أخطاء لكل صوت، فتُظهر اللوحات أكثر الأصوات احتياجًا للتدريب. مفرد بسيط في
/// الذاكرة (محاكاة) — يُستبدل لاحقًا بتجميع `/progress` من الخادم.
class WeakSoundsTracker {
  // تسمية الفونيم → (عدد الأخطاء، إجمالي المحاولات على هذا الصوت).
  final Map<String, _SoundStat> _stats = {};

  /// يغذّي المتتبّع بنتيجة تحليل واحدة.
  void record(SpeechAnalysis a) {
    for (final p in a.phonemes) {
      if (p.expected.isEmpty) continue; // نتجاهل الأصوات الزائدة (لا هدف لها)
      final s = _stats.putIfAbsent(p.label, () => _SoundStat());
      s.attempts++;
      if (p.error != PhonemeError.correct) s.errors++;
    }
  }

  /// أكثر [n] أصوات احتياجًا للتدريب (الأعلى نسبة خطأ ثم الأكثر تكرارًا).
  List<WeakSound> top([int n = 8]) {
    final list = _stats.entries
        .where((e) => e.value.errors > 0)
        .map((e) => WeakSound(
              label: e.key,
              errors: e.value.errors,
              attempts: e.value.attempts,
            ))
        .toList()
      ..sort((a, b) {
        final c = b.errorRate.compareTo(a.errorRate);
        return c != 0 ? c : b.errors.compareTo(a.errors);
      });
    return list.take(n).toList();
  }

  bool get isEmpty => _stats.values.every((s) => s.errors == 0);

  void clear() => _stats.clear();
}

class _SoundStat {
  int errors = 0;
  int attempts = 0;
}

/// عنصر في خريطة الأصوات الضعيفة.
class WeakSound {
  final String label;
  final int errors;
  final int attempts;
  const WeakSound({
    required this.label,
    required this.errors,
    required this.attempts,
  });

  double get errorRate => attempts == 0 ? 0 : errors / attempts;
}
