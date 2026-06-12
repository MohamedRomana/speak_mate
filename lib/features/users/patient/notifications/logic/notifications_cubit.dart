import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/logic/action_state.dart';
import '../../../../../core/networking/api_result.dart';
import '../data/models/notification_item.dart';
import '../data/repos/notifications_repo.dart';

/// كيوبت الإشعارات — تحميل + تعليم الكل كمقروء.
class NotificationsCubit extends Cubit<ActionState> {
  final NotificationsRepo _repo;
  NotificationsCubit(this._repo) : super(const ActionState.idle());

  List<NotificationItem> items = [];

  int get unreadCount => items.where((n) => !n.read).length;

  Future<void> load() async {
    emit(const ActionState.loading());
    final res = await _repo.getNotifications();
    if (isClosed) return;
    if (res is Failure<List<NotificationItem>>) {
      emit(ActionState.error(res.error.message ?? ''));
      return;
    }
    items = (res as Success<List<NotificationItem>>).data;
    emit(const ActionState.success());
  }

  void markAllRead() {
    items = items.map((n) => n.copyWith(read: true)).toList();
    emit(const ActionState.success());
  }
}
