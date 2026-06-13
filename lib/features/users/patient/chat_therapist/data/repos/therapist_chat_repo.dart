/// مستودع محادثة الأخصائي — mock (ردود داعمة + سجلّ ابتدائي).
class TherapistChatRepo {
  String therapistName(String lang) =>
      lang == 'en' ? 'Dr. Sara Al-Mahdi' : 'د. سارة المهدي';

  /// رد الأخصائي (mock) بناءً على نص المستخدم.
  String reply(String userText, String lang) {
    final t = userText.toLowerCase();
    final en = lang == 'en';
    bool has(List<String> k) => k.any((e) => t.contains(e));

    if (has(['موعد', 'جلسة', 'session', 'appoint'])) {
      return en
          ? 'Sure! I have a slot tomorrow at 4 PM. Does that work for you?'
          : 'بالتأكيد! عندي موعد متاح غداً الساعة 4 عصراً. يناسبك؟';
    }
    if (has(['تمرين', 'exercise', 'واجب', 'homework'])) {
      return en
          ? 'Please practice the "R" sound exercises 10 minutes daily and send me a recording 😊'
          : 'من فضلك تمرّن على مخارج حرف الراء 10 دقائق يومياً وابعتلي تسجيل 😊';
    }
    if (has(['شكر', 'thank'])) {
      return en ? "You're most welcome! 🌟" : 'العفو! دايماً في خدمتك 🌟';
    }
    if (has(['سلام', 'مرحب', 'hi', 'hello', 'اهلا', 'أهلا'])) {
      return en
          ? 'Hello! How is the practice going today?'
          : 'أهلاً! كيف تسير التمارين اليوم؟';
    }
    return en
        ? "Got it 👍 I'll review this and get back to you shortly."
        : 'تمام 👍 هراجع ده وأرد عليك حالاً.';
  }
}
