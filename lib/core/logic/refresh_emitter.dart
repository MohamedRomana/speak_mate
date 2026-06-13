import 'package:flutter_bloc/flutter_bloc.dart';

import 'action_state.dart';

/// Mixin يضمن إعادة بناء الواجهة عند كل تحديث حتى لو تطابقت الحالة منطقياً.
///
/// السبب: حالات Freezed تطبّق value-equality، و bloc يُسقط أي حالة مساوية للحالة
/// السابقة (`state == _state`). لذا تكرار `emit(const ActionState.success())`
/// لا يُعيد البناء. هنا نُصدر success برسالة فريدة `#n` (تتجاهلها الواجهة عبر
/// [isRefreshMessage]) لضمان rebuild دائماً مع الاحتفاظ بـ `state is ActionSuccess`.
mixin RefreshEmitter on Cubit<ActionState> {
  int _rev = 0;

  /// إعادة بناء بحت — البيانات تُقرأ من حقول الـ Cubit.
  void refresh() => emit(ActionState.success('#${_rev++}'));
}

/// هل رسالة الـ success مجرّد إشارة rebuild (لا تُعرض للمستخدم)؟
bool isRefreshMessage(String? message) =>
    message != null && message.startsWith('#');
