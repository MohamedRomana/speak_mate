import 'package:get_it/get_it.dart';

import '../../features/auth/data/repos/auth_repo.dart';

final getIt = GetIt.instance;

/// تسجيل كل الـ Repos/Services. أي feature جديدة تضيف تسجيلها هنا.
Future<void> setUpGetIt() async {
  // ---- المصادقة (Auth) ----
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepo());
}
