// اختبار يعيد إنتاج سيناريو: Splash → اختيار الدور → الدخول، ويتأكد من عدم
// حدوث خطأ تخطيط (RenderBox not laid out / hasSize) في AnimatedAuthBackground
// أثناء الانتقال. نتجنّب pumpAndSettle لأن الخلفية فيها أنميشن متكرّر لا ينتهي.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speak_mate/core/cache/cache_helper.dart';
import 'package:speak_mate/core/di/dependancy_injection.dart';
import 'package:speak_mate/core/routing/app_router.dart';
import 'package:speak_mate/core/widgets/auth_background.dart';
import 'package:speak_mate/main.dart';

void main() {
  testWidgets('Role selection → Login: no layout (hasSize) exception',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    // نجمع أخطاء التخطيط فقط (نتجاهل أخطاء تحميل الصور في بيئة الاختبار).
    final layoutErrors = <String>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('was not laid out') ||
          msg.contains('hasSize') ||
          msg.contains('_debugDoingThisLayout') ||
          msg.contains('RenderBox was not laid out')) {
        layoutErrors.add(msg);
      }
      // نتجاهل أخطاء تحميل الأصول/الصور في بيئة الاختبار الـ headless فقط
      // (logo.png لا يُبنى ضمن bundle الاختبار) — لا تخصّ منطق التطبيق.
      final isAssetOrImage = msg.contains('Unable to load asset') ||
          msg.contains('image codec') ||
          msg.contains('logo.png') ||
          msg.contains('image');
      if (!isAssetOrImage) {
        previous?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = previous);

    SharedPreferences.setMockInitialValues({'lang': 'ar', 'intro': true});
    await CacheHelper.init();
    await getIt.reset();
    await setUpGetIt();
    await EasyLocalization.ensureInitialized();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/Lang',
        startLocale: const Locale('ar'),
        fallbackLocale: const Locale('ar'),
        useOnlyLangCode: true,
        child: MyApp(appRouter: AppRouter()),
      ),
    );

    // تحميل الترجمة (FutureBuilder) ثم تشغيل مؤقّت الـ Splash (2.2s).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600)); // ينهي تحميل اللغة
    await tester.pump(const Duration(milliseconds: 2400)); // يطلق مؤقّت Splash
    await tester.pump(const Duration(milliseconds: 600)); // انتقال لاختيار الدور

    expect(find.byType(AnimatedAuthBackground), findsOneWidget);

    final patientRole = find.text('ولي أمر / طفل');
    expect(patientRole, findsOneWidget);

    // الضغط على الدور → الانتقال لشاشة الدخول (هنا كان يحدث الكراش).
    await tester.tap(patientRole);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    // التحقق الأساسي: لا يوجد أي خطأ تخطيط من نوع hasSize / not laid out.
    expect(layoutErrors, isEmpty,
        reason: 'وُجدت أخطاء تخطيط:\n${layoutErrors.join('\n---\n')}');

    // وصلنا لشاشة الدخول.
    expect(find.byType(AnimatedAuthBackground), findsWidgets);
  });
}
