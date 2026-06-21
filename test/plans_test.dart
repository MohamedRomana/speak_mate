import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speak_mate/core/cache/cache_helper.dart';
import 'package:speak_mate/core/networking/api_result.dart';
import 'package:speak_mate/features/shared/plans/data/models/therapy_plan.dart';
import 'package:speak_mate/features/shared/plans/data/repos/plans_repo.dart';
import 'package:speak_mate/features/shared/plans/logic/assign_plan_cubit.dart';
import 'package:speak_mate/features/shared/plans/logic/create_plan_cubit.dart';
import 'package:speak_mate/features/shared/plans/logic/my_plan_cubit.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
  });

  test('PlansRepo (mock) يرجّع قوالب وخطة نشطة', () async {
    final repo = PlansRepo();
    final templates = await repo.getTemplates();
    expect(templates.isSuccess, isTrue);

    final mine = await repo.getMyPlan();
    expect(mine.isSuccess, isTrue);
  });

  test('AssignPlanCubit: تحميل ثم اختيار ثم إسناد ينجح', () async {
    final cubit = AssignPlanCubit(PlansRepo(), patientId: 'pt_1');
    await cubit.load();
    expect(cubit.phase, AssignPhase.ready);
    expect(cubit.templates, isNotEmpty);
    expect(cubit.selectedId, isNotNull); // أول قالب محدّد افتراضيًا

    cubit.select(cubit.templates.last.id);
    expect(cubit.selectedId, cubit.templates.last.id);

    final ok = await cubit.assign();
    expect(ok, isTrue);
    expect(cubit.phase, AssignPhase.assigned);
    await cubit.close();
  });

  test('MyPlanCubit: تحميل الخطة النشطة', () async {
    final cubit = MyPlanCubit(PlansRepo());
    await cubit.load();
    expect(cubit.phase, MyPlanPhase.ready);
    expect(cubit.plan, isNotNull);
    expect(cubit.plan!.targets, isNotEmpty);
    await cubit.close();
  });

  test('CreatePlanCubit: تحقّق + حفظ خطة مخصّصة', () async {
    final cubit = CreatePlanCubit(PlansRepo());
    expect(cubit.isValid, isFalse); // العنوان فارغ
    cubit.setTitle('برنامج تجريبي');
    cubit.toggleSound('ر');
    expect(cubit.isValid, isTrue);

    final plan = await cubit.save();
    expect(plan, isNotNull);
    expect(plan!.title, 'برنامج تجريبي');
    expect(plan.targetSounds, contains('ر'));
    expect(plan.targets, isNotEmpty);
    await cubit.close();
  });

  test('AssignPlanCubit.addTemplate يضيف الخطة ويحدّدها', () async {
    final cubit = AssignPlanCubit(PlansRepo(), patientId: 'pt_2');
    await cubit.load();
    const created = TherapyPlan(id: 'custom_1', title: 'مخصّصة', goal: 'هدف');
    cubit.addTemplate(created);
    expect(cubit.templates.first.id, 'custom_1');
    expect(cubit.selectedId, 'custom_1');
    await cubit.close();
  });
}
