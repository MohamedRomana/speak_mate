import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../gen/fonts.gen.dart';

/// مشغّل رسالة صوتية: تشغيل/إيقاف + موجة صوتية + المدّة. يعمل من ملف محلي.
class VoicePlayer extends StatefulWidget {
  final String? path;
  final int durationMs;

  /// لون مناسب للخلفية (أبيض على فقاعتي وغيره على فقاعة الطرف الآخر).
  final Color foreground;
  final Color trackColor;
  final double width;

  const VoicePlayer({
    super.key,
    required this.path,
    required this.durationMs,
    required this.foreground,
    required this.trackColor,
    this.width = 150,
  });

  @override
  State<VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<VoicePlayer> {
  final PlayerController _controller = PlayerController();
  StreamSubscription<PlayerState>? _stateSub;
  bool _prepared = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _prepare();
    _stateSub = _controller.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playing = state.isPlaying);
    });
  }

  Future<void> _prepare() async {
    final path = widget.path;
    if (path == null) return;
    try {
      await _controller.preparePlayer(path: path, noOfSamples: 40);
      await _controller.setFinishMode(finishMode: FinishMode.pause);
      if (mounted) setState(() => _prepared = true);
    } catch (_) {
      // تعذّر تجهيز الملف — يُعرض الزر مع شريط ثابت.
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (!_prepared) return;
    if (_playing) {
      await _controller.pausePlayer();
    } else {
      await _controller.startPlayer();
    }
  }

  String _fmt(int ms) {
    final d = Duration(milliseconds: ms);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.foreground;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: Icon(
            _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: fg,
            size: 28.w,
          ),
        ),
        SizedBox(width: 6.w),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 26.h,
              width: widget.width.w,
              child: _prepared
                  ? AudioFileWaveforms(
                      size: Size(widget.width.w, 26.h),
                      playerController: _controller,
                      enableSeekGesture: true,
                      waveformType: WaveformType.fitWidth,
                      playerWaveStyle: PlayerWaveStyle(
                        fixedWaveColor: widget.trackColor,
                        liveWaveColor: fg,
                        waveThickness: 2.5,
                        spacing: 4.w,
                      ),
                    )
                  : Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        height: 3.h,
                        width: widget.width.w,
                        color: widget.trackColor,
                      ),
                    ),
            ),
            SizedBox(height: 2.h),
            Text(
              _fmt(widget.durationMs),
              style: TextStyle(
                fontSize: 10.sp,
                color: fg,
                fontFamily: FontFamily.tajawalRegular,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
