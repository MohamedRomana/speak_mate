enum MsgSender { me, therapist }

enum MsgType { text, voice, image }

/// حالة تسليم رسالة المستخدم (زر علامات الصح كواتساب).
enum MsgStatus { sending, sent, delivered, read }

/// رسالة في محادثة الأخصائي.
class TMessage {
  final String id;
  final MsgSender sender;
  final MsgType type;
  final String text;
  final int audioSeconds;
  final String? imagePath;
  final DateTime time;
  MsgStatus status;
  final TReplyRef? replyTo;

  TMessage({
    required this.id,
    required this.sender,
    required this.time,
    this.type = MsgType.text,
    this.text = '',
    this.audioSeconds = 0,
    this.imagePath,
    this.status = MsgStatus.read,
    this.replyTo,
  });

  bool get isMe => sender == MsgSender.me;
}

/// مرجع مختصر لرسالة يُرد عليها (اقتباس).
class TReplyRef {
  final MsgSender sender;
  final MsgType type;
  final String text;

  const TReplyRef({
    required this.sender,
    required this.type,
    required this.text,
  });

  factory TReplyRef.from(TMessage m) =>
      TReplyRef(sender: m.sender, type: m.type, text: m.text);
}
