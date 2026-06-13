import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../gen/fonts.gen.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../logic/chat_cubit.dart';

/// شريط إدخال المساعد الذكي — نص + إرسال + تسجيل صوتي حقيقي.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final RecorderController _rec = RecorderController();
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
    context.read<ChatCubit>().send(_controller.text);
    _controller.clear();
    setState(() {});
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
      context.read<ChatCubit>().sendVoice(path, ms);
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
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: _recording ? _recordingRow() : _normalRow(),
      ),
    );
  }

  Widget _normalRow() {
    final hasText = _controller.text.trim().isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _send(),
              minLines: 1,
              maxLines: 4,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.mainText,
                fontFamily: FontFamily.tajawalRegular,
              ),
              decoration: InputDecoration(
                hintText: LocaleKeys.typeMessage.tr(),
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.secondaryText,
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: hasText
              ? _send
              : () {
                  HapticFeedback.mediumImpact();
                  _startRecording();
                },
          child: _Circle(icon: hasText ? Icons.send_rounded : Icons.mic_rounded),
        ),
      ],
    );
  }

  Widget _recordingRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: _cancelRecording,
          child: Icon(Icons.delete_outline_rounded,
              color: AppColors.error, size: 26.w),
        ),
        SizedBox(width: 8.w),
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
                Container(
                  width: 11.w,
                  height: 11.w,
                  decoration: const BoxDecoration(
                      color: AppColors.error, shape: BoxShape.circle),
                ),
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
          child: const _Circle(icon: Icons.send_rounded),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final IconData icon;
  const _Circle({required this.icon});

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
