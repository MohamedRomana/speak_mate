// اختبار ودجت تكاملي للشاشات الجديدة: يتأكد أنها تُبنى وتعرض بياناتها (mock) دون
// أخطاء تخطيط (RenderFlex/hasSize) — بنفس إطار MyApp (EasyLocalization +
// ScreenUtilInit + MaterialApp بثيم التطبيق).
//
// ملاحظة: نُبقي EasyLocalization مثبّتًا مرّة واحدة ونبدّل الشاشة قيد الفحص عبر
// ValueNotifier، لأن تركيب/تفكيك EasyLocalization بين اختبارات متعددة يفقد ذاكرة
// الترجمة المحمّلة فتظهر شجرة فارغة. كل الشاشات تُفحص ضمن اختبار واحد.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speak_mate/core/cache/cache_helper.dart';
import 'package:speak_mate/core/di/dependancy_injection.dart';
import 'package:speak_mate/core/theme/app_theme.dart';
import 'package:speak_mate/features/shared/appointments/ui/appointments_screen.dart';
import 'package:speak_mate/features/shared/appointments/ui/therapist_schedule_screen.dart';
import 'package:speak_mate/features/shared/billing/ui/subscription_screen.dart';
import 'package:speak_mate/features/shared/plans/ui/my_plan_screen.dart';
import 'package:speak_mate/features/adult/ui/adult_home.dart';
import 'package:speak_mate/features/clinic/ui/clinic_doctors_screen.dart';
import 'package:speak_mate/features/clinic/ui/clinic_financials_screen.dart';
import 'package:speak_mate/features/clinic/ui/clinic_home.dart';
import 'package:speak_mate/features/shared/account/ui/account_screen.dart';
import 'package:speak_mate/features/shared/family/ui/family_screen.dart';
import 'package:speak_mate/features/shared/support/ui/support_screen.dart';
import 'package:speak_mate/features/therapist/data/models/therapist_patient.dart';
import 'package:speak_mate/features/therapist/ui/patient_detail_screen.dart';
import 'package:speak_mate/features/users/patient/aac/data/repos/aac_repo.dart';
import 'package:speak_mate/features/users/patient/aac/logic/aac_cubit.dart';
import 'package:speak_mate/features/users/patient/aac/ui/aac_screen.dart';

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

    // 4) جدول مواعيد الأخصائي → اسم مريض من طلبات الـ mock يظهر.
    await show(const TherapistScheduleScreen());
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.textContaining('أحمد محمد'), findsWidgets);

    // 5) ملف المريض (أخصائي) → خريطة الأصوات الضعيفة + التسجيلات + رسم التقدّم.
    await show(const PatientDetailScreen(patient: _mockPatient));
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.textContaining('أحمد محمد'), findsWidgets);

    // 6) لوحة العيادة → إحصاءات + مواعيد اليوم + فواتير.
    await show(const ClinicHomeScreen());
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.byType(Scaffold), findsWidgets);

    // 7) لوحة الكبار (إعادة التأهيل) → وحدات + إحصاءات تعافٍ.
    await show(const AdultHomeScreen());
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.byType(Scaffold), findsWidgets);

    // 8) لوح التواصل (AAC) → شبكة رموز + شريط الجملة.
    await show(
      BlocProvider(
        create: (_) => AacCubit(getIt<AacRepo>())..load(),
        child: const AacScreen(),
      ),
    );
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.byType(Text), findsWidgets);

    // 9) حساب المستخدم (أدوار غير الطفل) → معلومات + تبويبات.
    await show(const AccountScreen());
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.byType(Scaffold), findsWidgets);

    // 10) الدعم والمساعدة → تواصل + أسئلة شائعة.
    await show(const SupportScreen());
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.textContaining('كيف'), findsWidgets);

    // 11) أطفالي (الباقة العائلية) → بطاقات الأطفال + إضافة.
    await show(const FamilyScreen());
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.textContaining('أحمد'), findsWidgets);

    // 12) إدارة أطباء العيادة → بطاقات الأطباء.
    await show(const ClinicDoctorsScreen());
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.textContaining('سارة المهدي'), findsWidgets);

    // 13) التقرير المالي للعيادة → إجماليات + إيرادات.
    await show(const ClinicFinancialsScreen());
    expect(layoutErrors, isEmpty, reason: layoutErrors.join('\n---\n'));
    expect(find.byType(Scaffold), findsWidgets);
  });
}

/// مريض تجريبي لشاشة تفاصيل الأخصائي (أصوات ضعيفة + تسجيلات + سلسلة دقة).
const _mockPatient = TherapistPatient(
  id: 'pt_test',
  name: 'أحمد محمد',
  age: 8,
  condition: PatientCondition.child,
  progress: 78,
  accuracy: 82,
  lastActive: 'اليوم',
  accuracySeries: [55, 60, 68, 72, 78, 80, 82],
  weakSounds: [
    WeakSoundStat('ر', 0.62),
    WeakSoundStat('س', 0.4),
    WeakSoundStat('ش', 0.28),
  ],
  recordings: [
    PatientRecording(
        id: 'r1',
        title: 'تمرين حرف الراء',
        durationSeconds: 47,
        accuracy: 80,
        dateLabel: '2026/06/15'),
  ],
);
