// محرّك تحليل الفونيمات (قلب التطبيق — AI Speech Engine جانب العميل).
//
// يحوّل الكلمة الهدف والنص المُتعرَّف عليه إلى تسلسل فونيمات، يحاذيهما
// (Needleman–Wunsch)، يصنّف كل فونيم (صحيح / محذوف / مُبدَل / مُشوَّه / زائد)،
// يحسب درجة موزونة 0..100 (الأصوات الصعبة وزنها أعلى)، ويولّد ملاحظة مناسبة
// للطفل (تشجيعية + إيموجي) أو للبالغ (إكلينيكية). يعمل بالكامل بدون باك-إند،
// ويُكمّل خطوات 2..5 من مخطّط AI Speech Engine في وثيقة المعمارية.

import 'speech_service.dart';

enum PhonemeError { correct, missing, substituted, distorted, extra }

/// نتيجة فونيم واحد بعد المحاذاة.
class PhonemeResult {
  final String expected; // رمز الفونيم المتوقَّع ('' لو زائد)
  final String? actual; // ما سُمِع فعلًا (للإبدال/التشويه/الزائد)
  final String label; // اسم مقروء، مثل: «ل (L)»
  final PhonemeError error;
  const PhonemeResult({
    required this.expected,
    required this.actual,
    required this.label,
    required this.error,
  });

  bool get isOk => error == PhonemeError.correct;
}

enum SpeechAudience { child, adult }

/// التحليل الكامل لمحاولة نطق واحدة.
class SpeechAnalysis {
  final String target;
  final String recognized;
  final int score; // 0..100
  final List<PhonemeResult> phonemes;
  final List<String> weakPhonemes; // تسميات الفونيمات الخاطئة (للهيت-ماب)
  final String focusLabel; // أهم فونيم يحتاج تدريب ('' لو لا يوجد)

  const SpeechAnalysis({
    required this.target,
    required this.recognized,
    required this.score,
    required this.phonemes,
    required this.weakPhonemes,
    required this.focusLabel,
  });

  bool get isCorrect => score >= 80;

  /// ملاحظة تحفيزية للطفل أو إكلينيكية للبالغ — تُحدِّد الصوت محلّ التركيز.
  String feedback(SpeechAudience audience) {
    if (audience == SpeechAudience.child) {
      if (isCorrect) {
        return score >= 92 ? 'نُطق رائع! 🌟🎉' : 'أحسنت! 👏 كمان شويّة وتبقى ممتاز 😊';
      }
      final f = focusLabel.isEmpty ? '' : ' ركّز على صوت «$focusLabel» 👅';
      return 'حاول تاني 💪$f';
    }
    // بالغ — إكلينيكي.
    if (isCorrect) {
      return 'دقّة النطق $score٪ — أداء ضمن النطاق الطبيعي.';
    }
    final errs = _clinicalErrorSummary();
    final rec = focusLabel.isEmpty ? '' : ' يُنصح بتمارين موجّهة على الفونيم «$focusLabel».';
    return 'دقّة النطق $score٪.${errs.isEmpty ? '' : ' $errs'}$rec';
  }

  String _clinicalErrorSummary() {
    final parts = <String>[];
    for (final p in phonemes) {
      switch (p.error) {
        case PhonemeError.missing:
          parts.add('حذف /${p.expected}/');
          break;
        case PhonemeError.substituted:
          parts.add('إبدال /${p.expected}/→/${p.actual}/');
          break;
        case PhonemeError.distorted:
          parts.add('تشويه /${p.expected}/');
          break;
        case PhonemeError.extra:
          parts.add('إقحام /${p.actual}/');
          break;
        case PhonemeError.correct:
          break;
      }
      if (parts.length >= 3) break;
    }
    return parts.isEmpty ? '' : 'أخطاء فونيمية: ${parts.join('، ')}.';
  }
}

/// محرّك التحليل (دوال صرفة، قابلة للاختبار وحدويًا).
abstract class PhonemeAnalyzer {
  PhonemeAnalyzer._();

  /// الأصوات الأصعب نطقًا (تُوزَن أعلى وتُرشَّح أولًا للتركيز).
  static const _hard = {'ر', 'ل', 'س', 'ث', 'ذ', 'ظ', 'ص', 'ض', 'ق', 'غ', 'ج', 'ش', 'ط'};

  /// عائلات مخارج متقاربة → الإبدال داخلها يُعدّ "تشويهًا" (درجة جزئية) لا إبدالًا كاملًا.
  static const List<Set<String>> _families = [
    {'ر', 'ل', 'غ'}, // الراء واللام والغين (شائعة عند الأطفال)
    {'س', 'ث', 'ص', 'ز'}, // الصفير
    {'ذ', 'ز', 'ظ', 'د'}, // أسنانية/مفخمة
    {'ت', 'ط', 'د', 'ض'}, // أسنانية لثوية
    {'ش', 'س', 'ج'}, // غارية
    {'ك', 'ق', 'غ', 'خ'}, // طبقية/لهوية
  ];

  /// أسماء مقروءة للحروف (مع تلميح لاتيني للبالغين/الأخصائيين).
  static const Map<String, String> _names = {
    'ا': 'ا (A)', 'ب': 'ب (B)', 'ت': 'ت (T)', 'ث': 'ث (Th)', 'ج': 'ج (J)',
    'ح': 'ح (Ḥ)', 'خ': 'خ (Kh)', 'د': 'د (D)', 'ذ': 'ذ (Dh)', 'ر': 'ر (R)',
    'ز': 'ز (Z)', 'س': 'س (S)', 'ش': 'ش (Sh)', 'ص': 'ص (Ṣ)', 'ض': 'ض (Ḍ)',
    'ط': 'ط (Ṭ)', 'ظ': 'ظ (Ẓ)', 'ع': 'ع (ʿ)', 'غ': 'غ (Gh)', 'ف': 'ف (F)',
    'ق': 'ق (Q)', 'ك': 'ك (K)', 'ل': 'ل (L)', 'م': 'م (M)', 'ن': 'ن (N)',
    'ه': 'ه (H)', 'و': 'و (W)', 'ي': 'ي (Y)',
  };

  static String _label(String ch) => _names[ch] ?? '$ch (${ch.toUpperCase()})';
  static int _weight(String ch) => _hard.contains(ch) ? 2 : 1;

  static bool _near(String a, String b) =>
      _families.any((f) => f.contains(a) && f.contains(b));

  /// يجزّئ النص إلى فونيمات (حروف مُطبَّعة، بلا فراغات/تشكيل).
  static List<String> tokenize(String input) {
    final n = SpeechMatch.normalize(input).replaceAll(' ', '');
    return n.split('').where((c) => c.trim().isNotEmpty).toList();
  }

  /// يحلّل محاولة نطق: محاذاة + تصنيف أخطاء + درجة موزونة + فونيم التركيز.
  static SpeechAnalysis analyze(String recognized, String target) {
    final exp = tokenize(target);
    final act = tokenize(recognized);

    // لو لم يُسمع شيء → كل الفونيمات محذوفة، درجة صفر.
    if (act.isEmpty) {
      final ph = exp
          .map((e) => PhonemeResult(
                expected: e,
                actual: null,
                label: _label(e),
                error: PhonemeError.missing,
              ))
          .toList();
      return SpeechAnalysis(
        target: target,
        recognized: recognized,
        score: 0,
        phonemes: ph,
        weakPhonemes: ph.map((p) => p.label).toList(),
        focusLabel: _focus(ph),
      );
    }

    final aligned = _align(exp, act);
    final phonemes = <PhonemeResult>[];
    double earned = 0, total = 0;

    for (final pair in aligned) {
      final e = pair[0]; // متوقَّع أو null
      final a = pair[1]; // فعلي أو null
      if (e != null && a != null) {
        total += _weight(e);
        if (e == a) {
          earned += _weight(e);
          phonemes.add(PhonemeResult(
              expected: e, actual: a, label: _label(e), error: PhonemeError.correct));
        } else if (_near(e, a)) {
          earned += _weight(e) * 0.5; // تشويه = درجة جزئية
          phonemes.add(PhonemeResult(
              expected: e, actual: a, label: _label(e), error: PhonemeError.distorted));
        } else {
          phonemes.add(PhonemeResult(
              expected: e, actual: a, label: _label(e), error: PhonemeError.substituted));
        }
      } else if (e != null) {
        total += _weight(e);
        phonemes.add(PhonemeResult(
            expected: e, actual: null, label: _label(e), error: PhonemeError.missing));
      } else if (a != null) {
        // إقحام صوت زائد — غرامة بسيطة على المجموع.
        total += 1;
        phonemes.add(PhonemeResult(
            expected: '', actual: a, label: _label(a), error: PhonemeError.extra));
      }
    }

    final score = total == 0 ? 0 : (earned / total * 100).round().clamp(0, 100);
    final weak = phonemes
        .where((p) => p.error != PhonemeError.correct && p.expected.isNotEmpty)
        .map((p) => p.label)
        .toSet()
        .toList();

    return SpeechAnalysis(
      target: target,
      recognized: recognized,
      score: score,
      phonemes: phonemes,
      weakPhonemes: weak,
      focusLabel: _focus(phonemes),
    );
  }

  /// أهم فونيم للتركيز: أعلى وزنًا بين الأخطاء (يفضّل الحذف ثم الإبدال).
  static String _focus(List<PhonemeResult> phonemes) {
    PhonemeResult? best;
    int bestRank = -1;
    for (final p in phonemes) {
      if (p.error == PhonemeError.correct || p.expected.isEmpty) continue;
      final sev = switch (p.error) {
        PhonemeError.missing => 3,
        PhonemeError.substituted => 2,
        PhonemeError.distorted => 1,
        _ => 0,
      };
      final rank = sev * 10 + _weight(p.expected);
      if (rank > bestRank) {
        bestRank = rank;
        best = p;
      }
    }
    return best?.label ?? '';
  }

  /// محاذاة Needleman–Wunsch ترجع أزواج [expected?, actual?].
  static List<List<String?>> _align(List<String> a, List<String> b) {
    final m = a.length, n = b.length;
    const gap = -1;
    int matchScore(String x, String y) => x == y ? 2 : (_near(x, y) ? 0 : -1);

    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    for (var i = 0; i <= m; i++) {
      dp[i][0] = i * gap;
    }
    for (var j = 0; j <= n; j++) {
      dp[0][j] = j * gap;
    }
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final diag = dp[i - 1][j - 1] + matchScore(a[i - 1], b[j - 1]);
        final up = dp[i - 1][j] + gap;
        final left = dp[i][j - 1] + gap;
        dp[i][j] = [diag, up, left].reduce((x, y) => x > y ? x : y);
      }
    }

    final out = <List<String?>>[];
    var i = m, j = n;
    while (i > 0 || j > 0) {
      if (i > 0 &&
          j > 0 &&
          dp[i][j] == dp[i - 1][j - 1] + matchScore(a[i - 1], b[j - 1])) {
        out.add([a[i - 1], b[j - 1]]);
        i--;
        j--;
      } else if (i > 0 && dp[i][j] == dp[i - 1][j] + gap) {
        out.add([a[i - 1], null]); // حذف
        i--;
      } else {
        out.add([null, b[j - 1]]); // إقحام
        j--;
      }
    }
    return out.reversed.toList();
  }
}
