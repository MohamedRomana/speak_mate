import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/app_constants.dart';
import 'ws_events.dart';

/// عميل WebSocket مع إعادة اتصال (backoff) + نبض (heartbeat) + بثّ أحداث مُطبّعة.
///
/// في وضع الـ mock (AppConstants.useMockData) لا يفتح اتصالاً حقيقيًا، بل يحاكي
/// أحداثًا دورية (progress.updated / speech.analyzed) ليعمل النظام كاملاً بدون
/// backend. عند توفّر السيرفر، يتصل فعليًا ويحوّل JSON إلى [RealtimeEvent].
class WebSocketClient {
  final _controller = StreamController<RealtimeEvent>.broadcast();
  final Random _rnd = Random();

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _heartbeat;
  Timer? _reconnect;
  Timer? _mockTimer;
  String? _url;
  String? _token;
  bool _connected = false;
  bool _disposed = false;
  int _attempt = 0;

  /// تيّار كل الأحداث.
  Stream<RealtimeEvent> get events => _controller.stream;

  /// تيّار مُفلتر لنوع حدث واحد.
  Stream<RealtimeEvent> on(RealtimeEventType type) =>
      events.where((e) => e.type == type);

  bool get isConnected => _connected;

  void connect({String? url, String? token}) {
    if (_disposed) return;
    _url = url;
    _token = token;
    if (AppConstants.useMockData) {
      _startMock();
      return;
    }
    _openSocket();
  }

  // ---- وضع المحاكاة (mock) ----
  void _startMock() {
    _connected = true;
    _mockTimer?.cancel();
    // حدث "تقدّم" دوري لمحاكاة بثّ السيرفر.
    _mockTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_disposed) return;
      _controller.add(RealtimeEvent(
        RealtimeEventType.progressUpdated,
        {'metric': 'accuracy', 'value': 70 + _rnd.nextInt(25)},
      ));
    });
  }

  /// محاكاة استلام نتيجة تحليل نطق (تُستدعى من طبقة الـ AI عند الحاجة).
  void emitMockSpeechAnalyzed({required int score}) {
    _controller.add(RealtimeEvent(
      RealtimeEventType.speechAnalyzed,
      {'score': score},
    ));
  }

  // ---- الاتصال الحقيقي ----
  void _openSocket() {
    if (_disposed || _url == null) return;
    try {
      final uri = Uri.parse(_token == null ? _url! : '$_url?token=$_token');
      _channel = WebSocketChannel.connect(uri);
      _sub = _channel!.stream.listen(
        _onData,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
      _connected = true;
      _attempt = 0;
      _startHeartbeat();
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onData(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      _controller.add(RealtimeEvent.fromJson(json));
    } catch (_) {
      // رسالة غير صالحة — تُتجاهل.
    }
  }

  /// إرسال حدث للسيرفر (نشط فقط في الاتصال الحقيقي).
  void send(RealtimeEvent event) {
    if (_connected && _channel != null) {
      _channel!.sink.add(jsonEncode(event.toJson()));
    }
  }

  void _startHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_connected) _channel?.sink.add(jsonEncode({'event': 'ping'}));
    });
  }

  void _scheduleReconnect() {
    _connected = false;
    _heartbeat?.cancel();
    _sub?.cancel();
    if (_disposed) return;
    _attempt++;
    final delay = Duration(seconds: min(30, 2 * _attempt)); // exponential-ish
    _reconnect?.cancel();
    _reconnect = Timer(delay, _openSocket);
  }

  void disconnect() {
    _connected = false;
    _heartbeat?.cancel();
    _reconnect?.cancel();
    _mockTimer?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _controller.close();
  }
}
