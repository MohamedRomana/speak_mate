import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logic/action_state.dart';
import '../../../../core/networking/api_result.dart';
import '../../data/models/user_role.dart';
import '../../data/repos/auth_repo.dart';

/// كيوبت استعادة كلمة المرور — يرسل رمز التحقق للبريد/الجوال.
class ForgotPasswordCubit extends Cubit<ActionState> {
  final AuthRepo _repo;
  final UserRole role;

  ForgotPasswordCubit(this._repo, {required this.role})
      : super(const ActionState.idle());

  final formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();

  String get identifier => identifierController.text.trim();

  Future<void> sendCode() async {
    emit(const ActionState.loading());
    final res = await _repo.sendResetCode(identifier);
    if (isClosed) return;
    res.when(
      success: (_) => emit(const ActionState.success()),
      error: (e) => emit(ActionState.error(e.message ?? '')),
    );
  }

  @override
  Future<void> close() {
    identifierController.dispose();
    return super.close();
  }
}
