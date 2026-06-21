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

  /// الاشتراك في أحداث "progress.updated" الحيّة → إضافة إشعار وتحديث الجرس فورًا.
  void _listenLive() {
    if (_ws == null) return;
    _liveSub ??= _ws.on(RealtimeEventType.progressUpdated).listen((e) {
      if (isClosed) return;
      final value = e.data['value'] ?? 0;
      items = [
        NotificationItem(
          id: 'live_${_liveCounter++}',
          type: NotificationType.achievement,
          title: LocaleKeys.liveUpdateTitle.tr(),
          body: LocaleKeys.liveUpdateBody.tr().replaceFirst('{}', '$value'),
          timeLabel: LocaleKeys.liveNow.tr(),
        ),
        ...items,
      ];
      refresh();
    });
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
