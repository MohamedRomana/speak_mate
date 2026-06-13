enum ChatSender { user, bot }

enum ChatMessageType { text, audio }

/// رسالة محادثة (نص أو صوت mock).
class ChatMessage {
  final String id;
  final ChatSender sender;
  final ChatMessageType type;
  final String text;
  final int audioSeconds; // لرسائل الصوت
  final String? voicePath;
  final String timeLabel;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    this.type = ChatMessageType.text,
    this.audioSeconds = 0,
    this.voicePath,
    this.timeLabel = '',
  });

  bool get isUser => sender == ChatSender.user;
}
