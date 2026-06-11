import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logic/action_state.dart';
import '../../../../core/networking/api_result.dart';
import '../../data/models/user_role.dart';
import '../../data/repos/auth_repo.dart';

/// كيوبت التحقق من رمز OTP. عدّاد إعادة الإرسال تتولّاه الشاشة (UI).
class OtpCubit extends Cubit<ActionState> {
  final AuthRepo _repo;
  final String identifier;
  final UserRole role;

  OtpCubit(this._repo, {required this.identifier, required this.role})
      : super(const ActionState.idle());

  String code = '';

  Future<void> verify() async {
    emit(const ActionState.loading());
    final res = await _repo.verifyOtp(identifier: identifier, code: code);
    if (isClosed) return;
    res.when(
      success: (_) => emit(const ActionState.success()),
      error: (e) => emit(ActionState.error(e.message ?? '')),
    );
  }

  /// إعادة إرسال الرمز — ترجع true عند النجاح ليعيد الـ UI تشغيل العدّاد.
  Future<bool> resend() async {
    final res = await _repo.sendResetCode(identifier);
    if (isClosed) return false;
    return res.when(
      success: (_) => true,
      error: (e) {
        emit(ActionState.error(e.message ?? ''));
        return false;
      },
    );
  }
}
