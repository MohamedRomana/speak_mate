// اختبار طبقة الزمن الحقيقي — يتأكد أن العميل يبثّ الأحداث (وضع mock) وأن الفلترة
// حسب النوع تعمل.

import 'package:flutter_test/flutter_test.dart';

import 'package:speak_mate/core/realtime/websocket_client.dart';
import 'package:speak_mate/core/realtime/ws_events.dart';

void main() {
  test('WebSocketClient emits mock speech.analyzed and filters by type',
      () async {
    final client = WebSocketClient();
    client.connect(); // mock mode (useMockData = true)

    final speechEvents = <RealtimeEvent>[];
    final sub =
        client.on(RealtimeEventType.speechAnalyzed).listen(speechEvents.add);

    client.emitMockSpeechAnalyzed(score: 88);
    await Future.delayed(const Duration(milliseconds: 20));

    expect(client.isConnected, isTrue);
    expect(speechEvents, hasLength(1));
    expect(speechEvents.first.type, RealtimeEventType.speechAnalyzed);
    expect(speechEvents.first.data['score'], 88);

    await sub.cancel();
    client.dispose();
  });

  test('RealtimeEvent JSON round-trips with backend wire names', () {
    final e = RealtimeEvent.fromJson({
      'event': 'progress.updated',
      'data': {'metric': 'accuracy', 'value': 80},
    });
    expect(e.type, RealtimeEventType.progressUpdated);
    expect(e.toJson()['event'], 'progress.updated');
  });
}
