import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/cache/cache_helper.dart';
import 'core/constants/colors.dart';
import 'core/di/dependancy_injection.dart';
import 'core/logic/settings_cubit.dart';
import 'core/networking/bloc_observer.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await CacheHelper.init();
  Bloc.observer = MyBlocObserver();
  await setUpGetIt();
  await EasyLocalization.ensureInitialized();

  final savedLang = CacheHelper.getLang();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      // العربية هي اللغة الافتراضية.
      startLocale: Locale(savedLang.isEmpty ? 'ar' : savedLang),
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      useOnlyLangCode: true,
      path: 'assets/Lang',
      child: MyApp(appRouter: AppRouter()),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit()),
            BlocProvider(create: (_) => SettingsCubit()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settings) {
                  return GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: MaterialApp(
                      // إعادة المفتاح عند تغيير اللغة تُعيد بناء كامل التطبيق
                      // فوراً باللغة الجديدة بدل بقاء النصوص القديمة.
                      key: ValueKey(context.locale.languageCode),
                      title: 'SpeakMate',
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.light,
                      darkTheme: AppTheme.dark,
                      themeMode: themeMode,
                      // يضبط ألوان الأسطح حسب الثيم الفعّال + يطبّق حجم النص
                      // (إمكانية الوصول) على كامل التطبيق قبل بناء أي شاشة.
                      builder: (context, child) {
                        AppColors.isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        AppColors.highContrast = settings.highContrast;
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: TextScaler.linear(settings.textScale),
                          ),
                          child: child ?? const SizedBox.shrink(),
                        );
                      },
                      localizationsDelegates: context.localizationDelegates,
                      supportedLocales: context.supportedLocales,
                      locale: context.locale,
                      onGenerateRoute: appRouter.onGenerateRoute,
                      initialRoute: Routes.splash,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
