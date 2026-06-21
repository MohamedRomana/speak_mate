/// نقاط نهاية VoiceBridge AI — REST v1 (مطابقة لوثيقة المعمارية §5).
/// الغلاف الموحّد للردود: `{ key: 1|0, msg, data }` — انظر [ApiService].
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = "https://api.voicebridge.ai/api/v1/";

  // ---- المصادقة ----
  static const String register = "auth/register";
  static const String login = "auth/login";
  static const String verifyOtp = "auth/otp/verify";
  static const String forgot = "auth/forgot";
  static const String reset = "auth/reset";
  static const String logout = "auth/logout";

  // ---- الحساب ----
  static const String me = "me";
  static const String updateMe = "me"; // PUT
  static const String avatar = "me/avatar";
  static const String dashboard = "me/dashboard"; // ملخّص لوحة المتدرّب
  static const String notifications = "me/notifications";

  // ---- الخطط والتمارين ----
  static const String plans = "plans";
  static String plan(String id) => "plans/$id";
  static const String exercises = "exercises"; // ?plan=
  static String exercise(String id) => "exercises/$id";

  // ---- الكلام / الذكاء الاصطناعي ----
  static const String sessions = "sessions";
  static String analyze(String sessionId) => "sessions/$sessionId/analyze";
  static String sessionResult(String sessionId) => "sessions/$sessionId/result";
  static const String progress = "progress"; // ?patient=&range=

  // ---- الأخصائي / العيادة ----
  static const String patients = "patients"; // ?filter=
  static String patient(String id) => "patients/$id";
  static String patientPlan(String id) => "patients/$id/plan";
  static const String appointments = "appointments";
  static String appointment(String id) => "appointments/$id";
  static String report(String patientId) => "reports/$patientId";

  // ---- المحادثة / الفوترة ----
  static const String chats = "chats";
  static String chatMessages(String chatId) => "chats/$chatId/messages";
  static const String invoices = "billing/invoices";
  static const String subscribe = "billing/subscribe";
}
