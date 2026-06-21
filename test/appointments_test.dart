import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speak_mate/core/cache/cache_helper.dart';
import 'package:speak_mate/features/shared/appointments/data/models/appointment.dart';
import 'package:speak_mate/features/shared/appointments/data/repos/appointments_repo.dart';
import 'package:speak_mate/features/shared/appointments/logic/appointments_cubit.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
  });

  test('تحميل المواعيد يفصل القادمة عن السابقة', () async {
    final cubit = AppointmentsCubit(AppointmentsRepo());
    await cubit.load();
    expect(cubit.phase, ApptPhase.ready);
    expect(cubit.upcoming, isNotEmpty);
    expect(cubit.past, isNotEmpty);
    // القادمة كلها مجدولة ومستقبلية.
    expect(cubit.upcoming.every((a) => a.isUpcoming), isTrue);
    await cubit.close();
  });

  test('الحجز يضيف موعدًا جديدًا للقائمة', () async {
    final cubit = AppointmentsCubit(AppointmentsRepo());
    await cubit.load();
    final before = cubit.upcoming.length;
    final ok = await cubit.book(
      therapist: const TherapistOption(id: 't1', name: 'د. سارة', specialty: 'نطق'),
      dateTime: DateTime.now().add(const Duration(days: 2)),
      type: AppointmentType.video,
    );
    expect(ok, isTrue);
    expect(cubit.upcoming.length, before + 1);
    await cubit.close();
  });

  test('الإلغاء يحوّل حالة الموعد إلى cancelled', () async {
    final cubit = AppointmentsCubit(AppointmentsRepo());
    await cubit.load();
    final id = cubit.upcoming.first.id;
    final ok = await cubit.cancel(id);
    expect(ok, isTrue);
    expect(cubit.items.firstWhere((a) => a.id == id).status,
        AppointmentStatus.cancelled);
    await cubit.close();
  });
}
