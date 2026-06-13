import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../gen/fonts.gen.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../data/models/therapist_message.dart';
import '../../logic/therapist_chat_cubit.dart';

/// شريط إدخال محادثة الأخصائي: نص + إرفاق صورة + تسجيل صوت حقيقي + معاينة رد.
class TChatInputBar extends StatefulWidget {
  const TChatInputBar({super.key});

  @override
  State<TChatInputBar> createState() => _TChatInputBarState();
}

class _TChatInputBarState extends State<TChatInputBar> {
  final _controller = TextEditingController();
  final RecorderController _rec = RecorderController();
  bool _hasText = false;
  bool _recording = false;
  final _stopwatch = Stopwatch();
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    _rec.dispose();
    super.dispose();
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    context.read<TherapistChatCubit>().sendText(_controller.text);
    _controller.clear();
    setState(() => _hasText = false);
  }

  Future<void> _attachImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (file != null && mounted) {
      context.read<TherapistChatCubit>().sendImage(file.path);
    }
  }

  Future<void> _startRecording() async {
    final granted = await _rec.checkPermission();
    if (!granted) return;
    await _rec.record();
    _stopwatch
      ..reset()
      ..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) setState(() => _elapsed = _stopwatch.elapsed);
    });
    setState(() => _recording = true);
  }

  Future<void> _stopAndSend() async {
    final ms = _stopwatch.elapsedMilliseconds;
    final path = await _rec.stop();
    _cleanup();
    if (path != null && ms > 500 && mounted) {
      context.read<TherapistChatCubit>().sendVoice(path, ms);
    }
  }

  Future<void> _cancelRecording() async {
    await _rec.stop();
    _cleanup();
  }

  void _cleanup() {
    _ticker?.cancel();
    _stopwatch.stop();
    if (mounted) {
      setState(() {
        _recording = false;
        _elapsed = Duration.zero;
      });
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TherapistChatCubit>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cubit.replyDraft != null && !_recording)
              _ReplyPreview(reply: cubit.replyDraft!),
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 8.h),
              child: _recording ? _recordingRow() : _normalRow(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _normalRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (v) =>
                        setState(() => _hasText = v.trim().isNotEmpty),
                    onSubmitted: (_) => _send(),
                    minLines: 1,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.mainText,
                      fontFamily: FontFamily.tajawalRegular,
                    ),
                    decoration: InputDecoration(
                      hintText: LocaleKeys.messageHint.tr(),
                      hintStyle: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.secondaryText,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _attachImage,
                  icon: Icon(Icons.attach_file_rounded,
                      color: AppColors.secondaryText, size: 22.w),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: _hasText
              ? _send
              : () {
                  HapticFeedback.mediumImpact();
                  _startRecording();
                },
          child: _SendCircle(
            icon: _hasText ? Icons.send_rounded : Icons.mic_rounded,
          ),
        ),
      ],
    );
  }

  Widget _recordingRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: _cancelRecording,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 26.w),
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Container(
            height: 46.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _PulsingDot(),
                SizedBox(width: 8.w),
                Text(
                  _fmt(_elapsed),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.mainText,
                    fontFamily: FontFamily.tajawalBold,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: AudioWaveforms(
                    size: Size(double.infinity, 32.h),
                    recorderController: _rec,
                    enableGesture: false,
                    waveStyle: WaveStyle(
                      waveColor: AppColors.primary,
                      showMiddleLine: false,
                      extendWaveform: true,
                      spacing: 4.w,
                      waveThickness: 2.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: _stopAndSend,
          child: const _SendCircle(icon: Icons.send_rounded),
        ),
      ],
    );
  }
}

class _SendCircle extends StatelessWidget {
  final IconData icon;
  const _SendCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
        child: Icon(icon, key: ValueKey(icon), color: Colors.white, size: 22.w),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_c),
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  final TReplyRef reply;
  const _ReplyPreview({required this.reply});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TherapistChatCubit>();
    final preview = switch (reply.type) {
      MsgType.voice => '🎤 ${LocaleKeys.voiceMessage.tr()}',
      MsgType.image => '📷 ${LocaleKeys.photo.tr()}',
      MsgType.text => reply.text,
    };
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 8.w, 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(10.r),
          border: const BorderDirectional(
              start: BorderSide(color: AppColors.primary, width: 3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text:
                        '${LocaleKeys.replyingTo.tr()} ${reply.sender == MsgSender.me ? LocaleKeys.you.tr() : LocaleKeys.chatWithTherapist.tr()}',
                    size: 10.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.primary,
                  ),
                  AppText(
                    text: preview,
                    size: 11.sp,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: cubit.clearReply,
              child: Icon(Icons.close_rounded,
                  size: 18.w, color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
