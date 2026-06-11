import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/logic/action_state.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/app_user.dart';
import '../../data/models/user_role.dart';
import '../../data/repos/auth_repo.dart';

/// كيوبت تسجيل الدخول — يحمل الـ controllers والفورم، وينفّذ النداء عبر [AuthRepo].
class LoginCubit extends Cubit<ActionState> {
  final AuthRepo _repo;
  final UserRole role;

  LoginCubit(this._repo, {required this.role})
      : super(const ActionState.idle());

  final formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = CacheHelper.getRememberMe();

  /// المستخدم الناتج بعد النجاح (تقرأه الـ UI للتنقّل).
  AppUser? user;

  Future<void> login() async {
    emit(const ActionState.loading());
    final res = await _repo.login(
      identifier: identifierController.text.trim(),
      password: passwordController.text,
      role: role,
    );
    await _handle(res);
  }

  Future<void> socialLogin(String provider) async {
    emit(const ActionState.loading());
    final res = await _repo.socialLogin(provider: provider, role: role);
    await _handle(res);
  }

  Future<void> _handle(ApiResult<AppUser> res) async {
    if (isClosed) return;
    if (res is Failure<AppUser>) {
      emit(ActionState.error(res.error.message ?? ''));
      return;
    }
    await _persist((res as Success<AppUser>).data);
    if (isClosed) return;
    emit(const ActionState.success(LocaleKeys.loginSuccess));
  }

  Future<void> _persist(AppUser u) async {
    user = u;
    await CacheHelper.setUserId(u.id);
    await CacheHelper.setUserType(u.role.key);
    await CacheHelper.setUserName(u.name);
    await CacheHelper.setRememberMe(rememberMe);
  }

  @override
  Future<void> close() {
    identifierController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
