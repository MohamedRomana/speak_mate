import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speak_mate/core/cache/cache_helper.dart';
import 'package:speak_mate/features/shared/billing/data/repos/billing_repo.dart';
import 'package:speak_mate/features/shared/billing/logic/billing_cubit.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
  });

  test('تحميل الباقات والاشتراك الحالي والفواتير', () async {
    final cubit = BillingCubit(BillingRepo());
    await cubit.load();
    expect(cubit.phase, BillingPhase.ready);
    expect(cubit.plans.length, greaterThanOrEqualTo(2));
    expect(cubit.current, isNotNull);
    expect(cubit.invoices, isNotEmpty);
    // الباقة الحالية مُعلّمة.
    expect(cubit.isCurrent(cubit.current!.planId), isTrue);
    await cubit.close();
  });

  test('الاشتراك في باقة يحدّث الباقة الحالية', () async {
    final cubit = BillingCubit(BillingRepo());
    await cubit.load();
    final premium = cubit.plans.firstWhere((p) => p.id == 'premium');
    final ok = await cubit.subscribe(premium.id);
    expect(ok, isTrue);
    expect(cubit.isCurrent('premium'), isTrue);
    await cubit.close();
  });
}
