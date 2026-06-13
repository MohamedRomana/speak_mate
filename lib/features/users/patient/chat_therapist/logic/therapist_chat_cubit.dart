import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/therapist_message.dart';
import '../data/repos/therapist_chat_repo.dart';

/// كيوبت محادثة الأخصائي (واتساب-ستايل). الحالة عدّاد إصدار والبيانات في الحقول.
class TherapistChatCubit extends Cubit<int> {
  final TherapistChatRepo _repo;
  final String lang;
  final Random _rnd = Random();

  TherapistChatCubit(this._repo, {required this.lang}) : super(0);

  final List<TMessage> messages = [];
  bool typing = false;
  TReplyRef? replyDraft;
  int _counter = 0;
  int _rev = 0;

  String get therapistName => _repo.therapistName(lang);

  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  String _id() => 'tm${_counter++}';

  void init() {
    final now = DateTime.now();
    messages.addAll([
      TMessage(
        id: _id(),
        sender: MsgSender.therapist,
        text: lang == 'en'
            ? 'Hi! Great work in our last session 👏'
            : 'أهلاً! عمل رائع في جلستنا الأخيرة 👏',
        time: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      TMessage(
        id: _id(),
        sender: MsgSender.me,
        text: lang == 'en' ? 'Thank you doctor 😊' : 'شكراً يا دكتورة 😊',
        time: now.subtract(const Duration(days: 1, hours: 2, minutes: 55)),
      ),
      TMessage(
        id: _id(),
        sender: MsgSender.therapist,
        text: lang == 'en'
            ? "Don't forget today's exercises 🎯"
            : 'لا تنسَ تمارين اليوم 🎯',
        time: now.subtract(const Duration(hours: 2)),
      ),
    ]);
    _emit();
  }

  void setReply(TMessage m) {
    replyDraft = TReplyRef.from(m);
    _emit();
  }

  void clearReply() {
    replyDraft = null;
    _emit();
  }

  void sendText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _sendMessage(TMessage(
      id: _id(),
      sender: MsgSender.me,
      type: MsgType.text,
      text: trimmed,
      time: DateTime.now(),
      status: MsgStatus.sending,
      replyTo: replyDraft,
    ));
  }

  void sendVoice() {
    _sendMessage(TMessage(
      id: _id(),
      sender: MsgSender.me,
      type: MsgType.voice,
      audioSeconds: 3 + _rnd.nextInt(20),
      time: DateTime.now(),
      status: MsgStatus.sending,
      replyTo: replyDraft,
    ));
  }

  void sendImage(String path) {
    _sendMessage(TMessage(
      id: _id(),
      sender: MsgSender.me,
      type: MsgType.image,
      imagePath: path,
      time: DateTime.now(),
      status: MsgStatus.sending,
      replyTo: replyDraft,
    ));
  }

  Future<void> _sendMessage(TMessage msg) async {
    messages.add(msg);
    replyDraft = null;
    _emit();

    await Future.delayed(const Duration(milliseconds: 400));
    if (isClosed) return;
    msg.status = MsgStatus.sent;
    _emit();

    await Future.delayed(const Duration(milliseconds: 500));
    if (isClosed) return;
    msg.status = MsgStatus.delivered;
    _emit();

    // الأخصائي يكتب ثم يرد، وتُعلَّم رسالتنا كمقروءة.
    await Future.delayed(const Duration(milliseconds: 500));
    if (isClosed) return;
    typing = true;
    _emit();

    await Future.delayed(const Duration(milliseconds: 1500));
    if (isClosed) return;
    typing = false;
    msg.status = MsgStatus.read;
    final userText = msg.type == MsgType.text ? msg.text : 'voice';
    messages.add(TMessage(
      id: _id(),
      sender: MsgSender.therapist,
      text: _repo.reply(userText, lang),
      time: DateTime.now(),
    ));
    _emit();
  }
}
