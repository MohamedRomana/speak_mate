/// أنواع أحداث الزمن الحقيقي (مطابقة لأحداث الـ backend عبر WebSocket).
enum RealtimeEventType {
  speechAnalyzed, // speech.analyzed
  messageSent, // message.sent
  progressUpdated, // progress.updated
  sessionUpdated, // session.updated
  callSignal, // call.signal
  unknown,
}

extension RealtimeEventTypeX on RealtimeEventType {
  /// الاسم على السلك (نفس صيغة الـ backend).
  String get wire => switch (this) {
        RealtimeEventType.speechAnalyzed => 'speech.analyzed',
        RealtimeEventType.messageSent => 'message.sent',
        RealtimeEventType.progressUpdated => 'progress.updated',
        RealtimeEventType.sessionUpdated => 'session.updated',
        RealtimeEventType.callSignal => 'call.signal',
        RealtimeEventType.unknown => 'unknown',
      };

  static RealtimeEventType fromWire(String? s) => switch (s) {
        'speech.analyzed' => RealtimeEventType.speechAnalyzed,
        'message.sent' => RealtimeEventType.messageSent,
        'progress.updated' => RealtimeEventType.progressUpdated,
        'session.updated' => RealtimeEventType.sessionUpdated,
        'call.signal' => RealtimeEventType.callSignal,
        _ => RealtimeEventType.unknown,
      };
}

/// حدث زمن حقيقي موحّد.
class RealtimeEvent {
  final RealtimeEventType type;
  final Map<String, dynamic> data;

  const RealtimeEvent(this.type, [this.data = const {}]);

  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    return RealtimeEvent(
      RealtimeEventTypeX.fromWire(json['event'] as String?),
      (json['data'] as Map<String, dynamic>?) ?? const {},
    );
  }

  Map<String, dynamic> toJson() => {'event': type.wire, 'data': data};
}
