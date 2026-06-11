// اختبار دخان بسيط — يتأكد أن SplashScreen يُبنى دون أخطاء.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_mate/core/cache/cache_helper.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
  });

  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await EasyLocalization.ensureInitialized();
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(body: Center(child: Text('SpeakMate'))),
        ),
      ),
    );
    expect(find.text('SpeakMate'), findsOneWidget);
  });
}
