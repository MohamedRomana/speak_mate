import 'package:get_it/get_it.dart';

import '../realtime/websocket_client.dart';
import '../../features/auth/data/repos/auth_repo.dart';
import '../../features/users/patient/aac/data/repos/aac_repo.dart';
import '../../features/users/patient/chat/data/repos/chatbot_repo.dart';
import '../../features/users/patient/chat_therapist/data/repos/therapist_chat_repo.dart';
import '../../features/users/patient/dashboard/data/repos/dashboard_repo.dart';
import '../../features/users/patient/exercises/data/repos/exercises_repo.dart';
import '../../features/users/patient/notifications/data/repos/notifications_repo.dart';
import '../../features/adult/data/repos/adult_repo.dart';
import '../../features/clinic/data/repos/clinic_repo.dart';
import '../../features/shared/gamification/data/repos/gamification_repo.dart';
import '../../features/therapist/data/repos/therapist_repo.dart';
import '../../features/users/patient/profile/data/repos/profile_repo.dart';
import '../../features/users/patient/reports/data/repos/reports_repo.dart';

final getIt = GetIt.instance;

/// تسجيل كل الـ Repos/Services. أي feature جديدة تضيف تسجيلها هنا.
Future<void> setUpGetIt() async {
  // ---- الزمن الحقيقي (WebSocket) ----
  getIt.registerLazySingleton<WebSocketClient>(() => WebSocketClient());

  // ---- المصادقة (Auth) ----
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepo());

  // ---- المتدرّب: الملف الشخصي ----
  getIt.registerLazySingleton<ProfileRepo>(() => ProfileRepo());

  // ---- المتدرّب: اللوحة والإشعارات ----
  getIt.registerLazySingleton<DashboardRepo>(() => DashboardRepo());
  getIt.registerLazySingleton<NotificationsRepo>(() => NotificationsRepo());

  // ---- المتدرّب: التمارين ----
  getIt.registerLazySingleton<ExercisesRepo>(() => ExercisesRepo());

  // ---- المتدرّب: لوح التواصل (AAC) ----
  getIt.registerLazySingleton<AacRepo>(() => AacRepo());

  // ---- المتدرّب: المساعد الذكي ----
  getIt.registerLazySingleton<ChatBotRepo>(() => ChatBotRepo());

  // ---- المتدرّب: محادثة الأخصائي ----
  getIt.registerLazySingleton<TherapistChatRepo>(() => TherapistChatRepo());

  // ---- المتدرّب: التقارير ----
  getIt.registerLazySingleton<ReportsRepo>(() => ReportsRepo());

  // ---- التلعيب (Gamification) ----
  getIt.registerLazySingleton<GamificationRepo>(() => GamificationRepo());

  // ---- وحدة الكبار (إعادة التأهيل) ----
  getIt.registerLazySingleton<AdultRepo>(() => AdultRepo());

  // ---- وحدة الأخصائي ----
  getIt.registerLazySingleton<TherapistRepo>(() => TherapistRepo());

  // ---- وحدة العيادة ----
  getIt.registerLazySingleton<ClinicRepo>(() => ClinicRepo());
}
