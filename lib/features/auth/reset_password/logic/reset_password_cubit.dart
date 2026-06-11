import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logic/action_state.dart';
import '../../../../core/networking/api_result.dart';
import '../../data/models/user_role.dart';
import '../../data/repos/auth_repo.dart';

/// كيوبت تعيين كلمة مرور جديدة بعد التحقق من الرمز.
class ResetPasswordCubit extends Cubit<ActionState> {
  final AuthRepo _repo;
  final String identifier;
  final UserRole role;

  ResetPasswordCubit(
    this._repo, {
    required this.identifier,
    required this.role,
  }) : super(const ActionState.idle());

  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  Future<void> submit() async {
    emit(const ActionState.loading());
    final res = await _repo.resetPassword(
      identifier: identifier,
      newPassword: passwordController.text,
    );
    if (isClosed) return;
    res.when(
      success: (_) => emit(const ActionState.success()),
      error: (e) => emit(ActionState.error(e.message ?? '')),
    );
  }

  @override
  Future<void> close() {
    passwordController.dispose();
    confirmController.dispose();
    return super.close();
  }
}
