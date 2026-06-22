import 'package:get_it/get_it.dart';

import '../networking/api_service.dart';
import '../realtime/websocket_client.dart';
import '../services/weak_sounds_tracker.dart';
import '../../features/auth/data/repos/auth_repo.dart';
import '../../features/users/patient/aac/data/repos/aac_repo.dart';
import '../../features/users/patient/chat/data/repos/chatbot_repo.dart';
import '../../features/users/patient/chat_therapist/data/repos/therapist_chat_repo.dart';
import '../../features/users/patient/dashboard/data/repos/dashboard_repo.dart';
import '../../features/users/patient/exercises/data/repos/exercises_repo.dart';
import '../../features/users/patient/notifications/data/repos/notifications_repo.dart';
import '../../features/adult/data/repos/adult_repo.dart';
import '../../features/clinic/data/repos/clinic_repo.dart';
import '../../features/shared/account/data/repos/account_repo.dart';
import '../../features/shared/appointments/data/repos/appointments_repo.dart';
import '../../features/shared/billing/data/repos/billing_repo.dart';
import '../../features/shared/family/data/repos/family_repo.dart';
import '../../features/shared/support/data/repos/support_repo.dart';
import '../../features/shared/gamification/data/repos/gamification_repo.dart';
import '../../features/shared/plans/data/repos/plans_repo.dart';
import '../../features/therapist/data/repos/therapist_repo.dart';
import '../../features/users/patient/profile/data/repos/profile_repo.dart';
import '../../features/users/patient/reports/data/repos/reports_repo.dart';

final getIt = GetIt.instance;

/// تسجيل كل الـ Repos/Services. أي feature جديدة تضيف تسجيلها هنا.
Future<void> setUpGetIt() async {
  // ---- الزمن الحقيقي (WebSocket) ----
  getIt.registerLazySingleton<WebSocketClient>(() => WebSocketClient());

  // ---- محرّك الكلام: متتبّع الأصوات الضعيفة (heatmap) ----
  getIt.registerLazySingleton<WeakSoundsTracker>(() => WeakSoundsTracker());

  // ---- عميل الـ API الحقيقي (يُستخدم عند useMockData == false) ----
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // ---- المصادقة (Auth) ----
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepo(api: getIt<ApiService>()));

  // ---- المتدرّب: الملف الشخصي ----
  getIt.registerLazySingleton<ProfileRepo>(
      () => ProfileRepo(api: getIt<ApiService>()));

  // ---- المتدرّب: اللوحة والإشعارات ----
  getIt.registerLazySingleton<DashboardRepo>(
      () => DashboardRepo(api: getIt<ApiService>()));
  getIt.registerLazySingleton<NotificationsRepo>(
      () => NotificationsRepo(api: getIt<ApiService>()));

  // ---- المتدرّب: التمارين ----
  getIt.registerLazySingleton<ExercisesRepo>(
      () => ExercisesRepo(api: getIt<ApiService>()));

  // ---- المتدرّب: لوح التواصل (AAC) ----
  getIt.registerLazySingleton<AacRepo>(() => AacRepo(api: getIt<ApiService>()));

  // ---- المتدرّب: المساعد الذكي ----
  getIt.registerLazySingleton<ChatBotRepo>(() => ChatBotRepo());

  // ---- المتدرّب: محادثة الأخصائي ----
  getIt.registerLazySingleton<TherapistChatRepo>(() => TherapistChatRepo());

  // ---- المتدرّب: التقارير ----
  getIt.registerLazySingleton<ReportsRepo>(
      () => ReportsRepo(api: getIt<ApiService>()));

  // ---- التلعيب (Gamification) ----
  getIt.registerLazySingleton<GamificationRepo>(() => GamificationRepo());

  // ---- الخطط العلاجية (مشتركة: أخصائي + متدرّب) ----
  getIt.registerLazySingleton<PlansRepo>(() => PlansRepo(api: getIt<ApiService>()));

  // ---- المواعيد (حجز/عرض/إلغاء) ----
  getIt.registerLazySingleton<AppointmentsRepo>(
      () => AppointmentsRepo(api: getIt<ApiService>()));

  // ---- الاشتراكات والفوترة ----
  getIt.registerLazySingleton<BillingRepo>(
      () => BillingRepo(api: getIt<ApiService>()));

  // ---- حساب المستخدم (أدوار غير الطفل) ----
  getIt.registerLazySingleton<AccountRepo>(
      () => AccountRepo(api: getIt<ApiService>()));

  // ---- الدعم والمساعدة ----
  getIt.registerLazySingleton<SupportRepo>(
      () => SupportRepo(api: getIt<ApiService>()));

  // ---- الأطفال (الباقة العائلية) ----
  getIt.registerLazySingleton<FamilyRepo>(
      () => FamilyRepo(api: getIt<ApiService>()));

  // ---- وحدة الكبار (إعادة التأهيل) ----
  getIt.registerLazySingleton<AdultRepo>(() => AdultRepo(api: getIt<ApiService>()));

  // ---- وحدة الأخصائي ----
  getIt.registerLazySingleton<TherapistRepo>(
      () => TherapistRepo(api: getIt<ApiService>()));

  // ---- وحدة العيادة ----
  getIt.registerLazySingleton<ClinicRepo>(() => ClinicRepo(api: getIt<ApiService>()));
}
