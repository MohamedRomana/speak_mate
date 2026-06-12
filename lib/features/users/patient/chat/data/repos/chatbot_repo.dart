/// مساعد ذكي وهمي (mock) — ردود داعمة بمطابقة كلمات مفتاحية، ثنائي اللغة.
/// عند توفّر API حقيقي (مثلاً Claude) نستبدل [reply] فقط.
class ChatBotRepo {
  /// ردود مقترحة سريعة.
  List<String> suggestedReplies(String lang) {
    if (lang == 'en') {
      return [
        'How can I improve my pronunciation?',
        "What's today's exercise?",
        'I feel frustrated',
      ];
    }
    return [
      'كيف أحسّن نطقي؟',
      'ما تمرين اليوم؟',
      'أشعر بالإحباط',
    ];
  }

  /// يولّد ردًّا داعمًا بناءً على نص المستخدم.
  String reply(String userText, String lang) {
    final t = userText.toLowerCase();
    final en = lang == 'en';

    bool has(List<String> keys) => keys.any((k) => t.contains(k));

    if (has(['pronoun', 'improve', 'نطق', 'أحسّن', 'احسن', 'تحسين'])) {
      return en
          ? 'Great question! Practice a little every day, listen carefully, then repeat slowly. Try the Articulation exercises — short daily sessions work best. You\'ve got this! 💪'
          : 'سؤال رائع! تدرّب قليلاً كل يوم: استمع جيدًا ثم كرّر ببطء. جرّب تمارين «مخارج الحروف» — الجلسات القصيرة اليومية أفضل شيء. أنت قادر! 💪';
    }
    if (has(['exercise', 'today', 'تمرين', 'اليوم', 'تمارين'])) {
      return en
          ? 'Today I suggest the "Repeat after me" articulation set — 3 quick words. Open the Exercises tab and tap Articulation to start. 🎯'
          : 'أقترح اليوم مجموعة «كرّر بعدي» لمخارج الحروف — ٣ كلمات سريعة. افتح تبويب «التمارين» واضغط «مخارج الحروف» لتبدأ. 🎯';
    }
    if (has(['frustrat', 'sad', 'tired', 'hard', 'إحباط', 'احباط', 'حزين', 'متعب', 'صعب', 'تعبت'])) {
      return en
          ? "It's completely okay to feel that way — every learner does. Progress takes time, and you're already moving forward. Take a short break, then try one small exercise. I'm proud of you. 🌟"
          : 'من الطبيعي تمامًا أن تشعر بذلك — كل متعلّم يمرّ بهذا. التقدّم يحتاج وقتًا، وأنت تتقدّم بالفعل. خذ استراحة قصيرة ثم جرّب تمرينًا صغيرًا. أنا فخور بك. 🌟';
    }
    if (has(['thank', 'شكر'])) {
      return en
          ? "You're very welcome! I'm always here whenever you need me. 😊"
          : 'العفو! أنا هنا دائمًا وقت ما تحتاجني. 😊';
    }
    if (has(['hi', 'hello', 'مرحب', 'اهلا', 'أهلا', 'سلام'])) {
      return en
          ? 'Hello! 👋 How are your exercises going today?'
          : 'أهلاً! 👋 كيف تسير تمارينك اليوم؟';
    }
    // افتراضي داعم
    return en
        ? "I'm here to support you on your speech journey. You can ask me about exercises, pronunciation tips, or how to stay motivated. 💙"
        : 'أنا هنا لأدعمك في رحلة النطق. تقدر تسألني عن التمارين، نصائح النطق، أو كيف تحافظ على حماسك. 💙';
  }
}
