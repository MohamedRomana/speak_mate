import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/logic/action_state.dart';
import '../../../../../core/logic/refresh_emitter.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../data/models/chat_message.dart';
import '../data/repos/chatbot_repo.dart';

/// كيوبت المحادثة مع المساعد الذكي.
class ChatCubit extends Cubit<ActionState> with RefreshEmitter {
  final ChatBotRepo _repo;
  final String lang;

  ChatCubit(this._repo, {required this.lang})
      : super(const ActionState.idle());

  final List<ChatMessage> messages = [];
  List<String> suggestions = [];
  bool isTyping = false;
  int _counter = 0;

  String _now() {
    final d = DateTime.now();
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _id() => 'm${_counter++}';

  void init() {
    messages.add(
      ChatMessage(
        id: _id(),
        sender: ChatSender.bot,
        text: LocaleKeys.chatGreeting.tr(),
        timeLabel: _now(),
      ),
    );
    suggestions = _repo.suggestedReplies(lang);
    refresh();
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isTyping) return;
    messages.add(
      ChatMessage(
        id: _id(),
        sender: ChatSender.user,
        text: trimmed,
        timeLabel: _now(),
      ),
    );
    suggestions = [];
    isTyping = true;
    refresh();
    await _botRespond(trimmed);
  }

  Future<void> sendVoice(String path, int durationMs) async {
    if (isTyping) return;
    messages.add(
      ChatMessage(
        id: _id(),
        sender: ChatSender.user,
        type: ChatMessageType.audio,
        text: '',
        voicePath: path,
        audioSeconds: (durationMs / 1000).round(),
        timeLabel: _now(),
      ),
    );
    suggestions = [];
    isTyping = true;
    refresh();
    await _botRespond('voice');
  }

  Future<void> _botRespond(String userText) async {
    await Future.delayed(const Duration(milliseconds: 1300));
    if (isClosed) return;
    isTyping = false;
    messages.add(
      ChatMessage(
        id: _id(),
        sender: ChatSender.bot,
        text: _repo.reply(userText, lang),
        timeLabel: _now(),
      ),
    );
    refresh();
  }
}
