import 'package:freezed_annotation/freezed_annotation.dart';

part 'action_state.freezed.dart';

/// حالة عامة لعمليات النماذج (إرسال/حفظ): خامل/جارٍ/نجاح/خطأ.
@freezed
class ActionState with _$ActionState {
  const factory ActionState.idle() = ActionIdle;
  const factory ActionState.loading() = ActionLoading;
  const factory ActionState.success([String? message]) = ActionSuccess;
  const factory ActionState.error(String message) = ActionError;
}
