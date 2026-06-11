import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/logic/action_state.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/app_user.dart';
import '../../data/models/user_role.dart';
import '../../data/repos/auth_repo.dart';

/// كيوبت إنشاء الحساب — يدعم حقول المتدرّب (العمر/نوع الصعوبة) والأخصائي
/// (التخصص/رقم الترخيص) حسب الدور.
class RegisterCubit extends Cubit<ActionState> {
  final AuthRepo _repo;
  final UserRole role;

  RegisterCubit(this._repo, {required this.role})
      : super(const ActionState.idle());

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  // متدرّب
  final ageController = TextEditingController();
  String? difficultyType;

  // أخصائي
  final specialtyController = TextEditingController();
  final licenseController = TextEditingController();

  bool agreeTerms = false;
  AppUser? user;

  void selectDifficulty(String key) {
    difficultyType = key;
    emit(const ActionState.idle()); // تحديث الاختيار في الـ UI
  }

  Future<void> register() async {
    emit(const ActionState.loading());
    final res = await _repo.register(
      name: nameController.text.trim(),
      identifier: identifierController.text.trim(),
      password: passwordController.text,
      role: role,
      age: int.tryParse(ageController.text.trim()),
      difficultyType: difficultyType,
      specialty: specialtyController.text.trim().isEmpty
          ? null
          : specialtyController.text.trim(),
      licenseNumber: licenseController.text.trim().isEmpty
          ? null
          : licenseController.text.trim(),
    );
    if (isClosed) return;
    if (res is Failure<AppUser>) {
      emit(ActionState.error(res.error.message ?? ''));
      return;
    }
    final u = (res as Success<AppUser>).data;
    user = u;
    await CacheHelper.setUserId(u.id);
    await CacheHelper.setUserType(u.role.key);
    await CacheHelper.setUserName(u.name);
    if (isClosed) return;
    emit(const ActionState.success(LocaleKeys.registerSuccess));
  }

  @override
  Future<void> close() {
    nameController.dispose();
    identifierController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    ageController.dispose();
    specialtyController.dispose();
    licenseController.dispose();
    return super.close();
  }
}
