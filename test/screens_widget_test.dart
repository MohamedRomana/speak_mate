// اختبار ودجت تكاملي للشاشات الجديدة: يتأكد أنها تُبنى وتعرض بياناتها (mock) دون
// أخطاء تخطيط (RenderFlex/hasSize) — بنفس إطار MyApp (EasyLocalization +
// ScreenUtilInit + MaterialApp بثيم التطبيق).
//
// ملاحظة: نُبقي EasyLocalization مثبّتًا مرّة واحدة ونبدّل الشاشة قيد الفحص عبر
// ValueNotifier، لأن تركيب/تفكيك EasyLocalization بين اختبارات متعددة يفقد ذاكرة
// الترجمة المحمّلة فتظهر شجرة فارغة. كل الشاشات تُفحص ضمن اختبار واحد.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speak_mate/core/cache/cache_helper.dart';
import 'package:speak_mate/core/di/dependancy_injection.dart';
import 'package:speak_mate/core/theme/app_theme.dart';
import 'package:speak_mate/features/shared/appointments/ui/appointments_screen.dart';
import 'package:speak_mate/features/shared/billing/ui/subscription_screen.dart';
import 'package:speak_mate/features/shared/plans/ui/my_plan_screen.dart';

void main() {
  final layoutErrors = <String>[];

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({'lang': 'ar'});
    await CacheHelper.init();
    await getIt.reset();
    await setUpGetIt();
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('الشاشات الجديدة تُبنى وتعرض بيانات mock دون أخطاء تخطيط',
      (tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    // نلتقط أخطاء التخطيط فقط، ونتجاهل ضوضاء بيئة الاختبار (أصول/صور/خطوط).
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('was not laid out') ||
          msg.contains('hasSize') ||
          msg.contains('RenderFlex overflowed') ||
          msg.contains('RenderBox was not laid out')) {
        layoutErrors.add(msg);
      }
      final isEnvNoise = msg.contains('Unable to load asset') ||
          msg.contains('image') ||
          msg.contains('google_fonts') ||
          msg.contains('Cairo');
      if (!isEnvNoise) previous?.call(details);
    };
    addTearDown(() => FlutterError.onError = previous);

    final current = ValueNotifier<Widget>(const SizedBox.shrink());

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/Lang',
        startLocale: const Locale('ar'),
        fallbackLocale: const Locale('ar'),
        useOnlyLangCode: true,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: ValueListenableBuilder<Widget>(
              valueListenable: current,
              builder: (_, w, __) => w,
            ),
          ),
        ),
      ),
    );

    Future<void> settle() async {
      await tester.pump();
      for (var i = 0; i < 14; i++) {
        await tester.pump(const Duration(milliseconds: 400));
      }
    }

    // تحميل ترجمة EasyLocalization مرّة واحدة.
    await settle();

    Future<void> show(Widget screen) async {
      current.value = screen;
      await settle();
    }

    // 1) خطّتي العلاجية → عنوان الخطة المُسنَدة يظهر.
    await show(const MyPlanScreen());
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.textContaining('برنامج حرف الراء'), findsWidgets);

    // 2) الاشتراك → باقة بريميوم تظهر.
    await show(const SubscriptionScreen());
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.textContaining('بريميوم'), findsWidgets);

    // 3) المواعيد → اسم أخصائي من المواعيد يظهر.
    await show(const AppointmentsScreen());
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.textContaining('سارة المهدي'), findsWidgets);
  });
}
