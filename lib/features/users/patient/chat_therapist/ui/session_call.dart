import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/helper/extentions.dart';
import '../../dashboard/data/models/session_model.dart';
import '../logic/call_cubit.dart';
import 'call_screen.dart';

/// يفتح شاشة مكالمة الجلسة (فيديو/صوت) التي تربط المتدرّب بالأخصائي.
/// تُستخدم من جهة المتدرّب (الطفل/البالغ) ومن جهة الأخصائي لبدء/الانضمام للجلسة.
Future<void> openSessionCall(
  BuildContext context, {
  required String therapistName,
  required bool isVideo,
}) {
  return context.pushScreen(
    BlocProvider(
      create: (_) => CallCubit(isVideo: isVideo)..start(),
      child: CallScreen(name: therapistName),
    ),
  );
}

/// يفتح المكالمة انطلاقًا من [SessionModel] (يستخدم وضعها فيديو/صوت).
Future<void> openCallForSession(BuildContext context, SessionModel session) {
  return openSessionCall(
    context,
    therapistName: session.therapistName,
    isVideo: session.mode.isVideo,
  );
}
