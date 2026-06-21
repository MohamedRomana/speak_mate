// اختبارات وحدة تثبت إصلاح إسقاط الحالات المتكرّرة (RefreshEmitter / revision-int):
// - المطابقة: اختيار خاطئ ثم صحيح يعمل (#5).
// - المساعد الذكي: أي رسالة تحصل على رد (#1).
// - AAC: كل ضغطة رمز تُحدّث الجملة وتُصدر حالة جديدة (#3).

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speak_mate/core/cache/cache_helper.dart';
import 'package:speak_mate/core/di/dependancy_injection.dart';
import 'package:speak_mate/core/services/weak_sounds_tracker.dart';
import 'package:speak_mate/features/users/patient/aac/data/repos/aac_repo.dart';
import 'package:speak_mate/features/users/patient/aac/logic/aac_cubit.dart';
import 'package:speak_mate/features/users/patient/chat/data/models/chat_message.dart';
import 'package:speak_mate/features/users/patient/chat/data/repos/chatbot_repo.dart';
import 'package:speak_mate/features/users/patient/chat/logic/chat_cubit.dart';
import 'package:speak_mate/features/users/patient/exercises/data/models/exercise_models.dart';
import 'package:speak_mate/features/users/patient/exercises/data/repos/exercises_repo.dart';
import 'package:speak_mate/features/users/patient/exercises/logic/exercise_player_cubit.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
    if (!getIt.isRegistered<WeakSoundsTracker>()) {
      getIt.registerLazySingleton<WeakSoundsTracker>(() => WeakSoundsTracker());
    }
  });

  test('#5 Sound matching: wrong then correct selection works', () async {
    final cubit = ExercisePlayerCubit(ExercisesRepo(),
        category: ExerciseCategory.soundMatch);
    await cubit.load();
    expect(cubit.items, isNotEmpty);

    final correct = cubit.current.correctIndex;
    final wrong = (correct + 1) % cubit.current.options.length;

    // اختيار خاطئ
    cubit.selectOption(wrong);
    expect(cubit.matchCorrect, isFalse);
    expect(cubit.phase, PlayerPhase.matchResult);

    // ثم اختيار صحيح — يجب أن يعمل (كان يُسقط سابقاً لتطابق الحالة)
    cubit.selectOption(correct);
    expect(cubit.matchCorrect, isTrue);

    await cubit.close();
  });

  test('#1 AI chatbot replies to any message', () async {
    final cubit = ChatCubit(ChatBotRepo(), lang: 'ar');
    cubit.init();
    final before = cubit.messages.length;

    cubit.send('رسالة عشوائية كده');
    // رسالة المستخدم تُضاف فوراً
    expect(cubit.messages.length, before + 1);
    expect(cubit.isTyping, isTrue);

    // ينتظر رد البوت
    await Future.delayed(const Duration(milliseconds: 1600));
    expect(cubit.messages.last.sender, ChatSender.bot);
    expect(cubit.isTyping, isFalse);

    await cubit.close();
  });

  test('#3 AAC: each symbol tap updates the sentence and emits', () async {
    final cubit = AacCubit(AacRepo());
    final emissions = <int>[];
    final sub = cubit.stream.listen((_) => emissions.add(1));

    await cubit.load();
    final symbol = cubit.currentSymbols.first;

    cubit.addToSentence(symbol);
    await Future.delayed(Duration.zero);
    cubit.addToSentence(symbol);
    await Future.delayed(Duration.zero);
    cubit.addToSentence(symbol);
    await Future.delayed(Duration.zero);

    expect(cubit.sentence.length, 3);
    // 3 إضافات يجب أن تُنتج 3 إصدارات (لم تعد تُسقط لتطابق الحالة)
    expect(emissions.length, greaterThanOrEqualTo(3));

    await sub.cancel();
    await cubit.close();
  });
}
