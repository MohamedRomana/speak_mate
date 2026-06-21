import 'package:flutter_test/flutter_test.dart';
import 'package:speak_mate/core/services/phoneme_analyzer.dart';
import 'package:speak_mate/core/services/weak_sounds_tracker.dart';

void main() {
  group('PhonemeAnalyzer', () {
    test('نطق مطابق تمامًا → درجة كاملة وكل الفونيمات صحيحة', () {
      final a = PhonemeAnalyzer.analyze('قمر', 'قمر');
      expect(a.score, 100);
      expect(a.isCorrect, isTrue);
      expect(a.weakPhonemes, isEmpty);
      expect(a.phonemes.every((p) => p.error == PhonemeError.correct), isTrue);
      expect(a.focusLabel, isEmpty);
    });

    test('لا شيء مسموع → درجة صفر وكل الفونيمات محذوفة', () {
      final a = PhonemeAnalyzer.analyze('', 'سمكة');
      expect(a.score, 0);
      expect(a.isCorrect, isFalse);
      expect(a.phonemes.every((p) => p.error == PhonemeError.missing), isTrue);
      expect(a.focusLabel, isNotEmpty);
    });

    test('إبدال داخل عائلة مخارج متقاربة → تشويه (درجة جزئية) لا إبدال كامل', () {
      // الراء↔الغين في نفس العائلة → distorted.
      final a = PhonemeAnalyzer.analyze('غمر', 'رمر');
      final first = a.phonemes.first;
      expect(first.error, PhonemeError.distorted);
      // درجة جزئية: ليست 100 وليست منخفضة جدًا.
      expect(a.score, greaterThan(50));
      expect(a.score, lessThan(100));
    });

    test('إبدال بعيد المخرج → substituted وفونيم تركيز محدّد', () {
      // الميم↔الباء ليست في نفس العائلة.
      final a = PhonemeAnalyzer.analyze('بمر', 'قمر');
      final sub =
          a.phonemes.where((p) => p.error == PhonemeError.substituted).toList();
      expect(sub, isNotEmpty);
      expect(a.focusLabel, isNotEmpty);
    });

    test('حذف فونيم صعب يرفع أولويته في فونيم التركيز', () {
      // هدف فيه "ر" (صعب) — نحذفها.
      final a = PhonemeAnalyzer.analyze('قم', 'قمر');
      final missing =
          a.phonemes.where((p) => p.error == PhonemeError.missing).toList();
      expect(missing, isNotEmpty);
      expect(a.focusLabel.contains('ر'), isTrue);
    });

    test('التطبيع: التشكيل والألف لا يؤثران على الدرجة', () {
      final a = PhonemeAnalyzer.analyze('قَمَر', 'قمر');
      expect(a.score, 100);
    });

    test('ملاحظة الطفل تشجيعية والبالغ إكلينيكية', () {
      final wrong = PhonemeAnalyzer.analyze('بمر', 'قمر');
      final child = wrong.feedback(SpeechAudience.child);
      final adult = wrong.feedback(SpeechAudience.adult);
      expect(child, contains('حاول'));
      expect(adult, contains('٪'));
      expect(adult, contains('فونيمية'));
    });
  });

  group('WeakSoundsTracker', () {
    test('يجمّع الأخطاء ويرتّب الأصوات حسب نسبة الخطأ', () {
      final t = WeakSoundsTracker();
      t.record(PhonemeAnalyzer.analyze('بمر', 'قمر')); // خطأ على ق
      t.record(PhonemeAnalyzer.analyze('قمر', 'قمر')); // كله صحيح
      final top = t.top();
      expect(t.isEmpty, isFalse);
      expect(top, isNotEmpty);
      // الصوت الأعلى يجب أن يكون له نسبة خطأ موجبة.
      expect(top.first.errorRate, greaterThan(0));
    });

    test('نطق مثالي لا يُسجَّل كأصوات ضعيفة', () {
      final t = WeakSoundsTracker();
      t.record(PhonemeAnalyzer.analyze('قمر', 'قمر'));
      expect(t.isEmpty, isTrue);
      expect(t.top(), isEmpty);
    });
  });
}
