import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/logic/action_state.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../data/models/chat_message.dart';
import '../data/repos/chatbot_repo.dart';

/// كيوبت المحادثة مع المساعد الذكي.
class ChatCubit extends Cubit<ActionState> {
  final ChatBotRepo _repo;
  final String lang;
  final Random _rnd = Random();

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
    emit(const ActionState.success());
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
    emit(const ActionState.success());
    await _botRespond(trimmed);
  }

  Future<void> sendVoice() async {
    if (isTyping) return;
    messages.add(
      ChatMessage(
        id: _id(),
        sender: ChatSender.user,
        type: ChatMessageType.audio,
        text: '',
        audioSeconds: 3 + _rnd.nextInt(12),
        timeLabel: _now(),
      ),
    );
    suggestions = [];
    isTyping = true;
    emit(const ActionState.success());
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
    emit(const ActionState.success());
  }
}
