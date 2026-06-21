import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/logic/action_state.dart';
import '../../../../../core/logic/refresh_emitter.dart';
import '../../../../../core/networking/api_result.dart';
import '../../../../../core/realtime/websocket_client.dart';
import '../../../../../core/realtime/ws_events.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../data/models/notification_item.dart';
import '../data/repos/notifications_repo.dart';

/// كيوبت الإشعارات — تحميل + تعليم الكل كمقروء + استقبال أحداث الزمن الحقيقي.
class NotificationsCubit extends Cubit<ActionState> with RefreshEmitter {
  final NotificationsRepo _repo;
  final WebSocketClient? _ws;
  StreamSubscription<RealtimeEvent>? _liveSub;
  int _liveCounter = 0;

  NotificationsCubit(this._repo, {WebSocketClient? ws})
      : _ws = ws,
        super(const ActionState.idle());

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
    refresh();
    _listenLive();
  }

  /// الاشتراك في أحداث الزمن الحقيقي الحيّة → إضافة إشعار وتحديث الجرس فورًا:
  /// progress.updated (تقدّم) / session.updated (تأكيد موعد) / plan.assigned (خطة).
  void _listenLive() {
    if (_ws == null) return;
    _liveSub ??= _ws.events.listen((e) {
      if (isClosed) return;
      final item = _itemFor(e);
      if (item == null) return;
      items = [item, ...items];
      refresh();
    });
  }

  /// يحوّل حدث زمن حقيقي إلى إشعار (أو null لو غير معنيّ به).
  NotificationItem? _itemFor(RealtimeEvent e) {
    final id = 'live_${_liveCounter++}';
    switch (e.type) {
      case RealtimeEventType.progressUpdated:
        final value = e.data['value'] ?? 0;
        return NotificationItem(
          id: id,
          type: NotificationType.achievement,
          title: LocaleKeys.liveUpdateTitle.tr(),
          body: LocaleKeys.liveUpdateBody.tr().replaceFirst('{}', '$value'),
          timeLabel: LocaleKeys.liveNow.tr(),
        );
      case RealtimeEventType.sessionUpdated:
        return NotificationItem(
          id: id,
          type: NotificationType.appointment,
          title: LocaleKeys.notifApptConfirmedTitle.tr(),
          body: LocaleKeys.notifApptConfirmedBody.tr()
              .replaceFirst('{}', '${e.data['therapist'] ?? ''}'),
          timeLabel: LocaleKeys.liveNow.tr(),
        );
      case RealtimeEventType.planAssigned:
        return NotificationItem(
          id: id,
          type: NotificationType.plan,
          title: LocaleKeys.notifPlanAssignedTitle.tr(),
          body: LocaleKeys.notifPlanAssignedBody.tr()
              .replaceFirst('{}', '${e.data['plan'] ?? ''}'),
          timeLabel: LocaleKeys.liveNow.tr(),
        );
      default:
        return null;
    }
  }

  void markAllRead() {
    items = items.map((n) => n.copyWith(read: true)).toList();
    refresh();
  }

  @override
  Future<void> close() {
    _liveSub?.cancel();
    return super.close();
  }
}
