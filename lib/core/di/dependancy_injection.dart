import 'package:get_it/get_it.dart';

import '../../features/auth/data/repos/auth_repo.dart';
import '../../features/users/patient/dashboard/data/repos/dashboard_repo.dart';
import '../../features/users/patient/exercises/data/repos/exercises_repo.dart';
import '../../features/users/patient/notifications/data/repos/notifications_repo.dart';
import '../../features/users/patient/profile/data/repos/profile_repo.dart';

final getIt = GetIt.instance;

/// تسجيل كل الـ Repos/Services. أي feature جديدة تضيف تسجيلها هنا.
Future<void> setUpGetIt() async {
  // ---- المصادقة (Auth) ----
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepo());

  // ---- المتدرّب: الملف الشخصي ----
  getIt.registerLazySingleton<ProfileRepo>(() => ProfileRepo());

  // ---- المتدرّب: اللوحة والإشعارات ----
  getIt.registerLazySingleton<DashboardRepo>(() => DashboardRepo());
  getIt.registerLazySingleton<NotificationsRepo>(() => NotificationsRepo());

  // ---- المتدرّب: التمارين ----
  getIt.registerLazySingleton<ExercisesRepo>(() => ExercisesRepo());
}
