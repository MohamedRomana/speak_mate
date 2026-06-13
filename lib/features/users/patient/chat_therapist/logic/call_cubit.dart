import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// مرحلة المكالمة.
enum CallPhase { connecting, ringing, connected, ended }

/// كيوبت مكالمة (صوتية/فيديو) — محاكاة كاملة بمؤقّت وأزرار تحكّم.
class CallCubit extends Cubit<int> {
  final bool isVideo;
  CallCubit({required this.isVideo}) : super(0);

  CallPhase phase = CallPhase.connecting;
  int seconds = 0;
  bool muted = false;
  bool speakerOn = true;
  bool videoOn = true;
  bool frontCamera = true;
  Timer? _timer;

  int _rev = 0;
  void _emit() {
    if (!isClosed) emit(++_rev);
  }

  String get durationLabel {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> start() async {
    phase = CallPhase.connecting;
    videoOn = isVideo;
    _emit();
    await Future.delayed(const Duration(milliseconds: 1400));
    if (isClosed || phase == CallPhase.ended) return;
    phase = CallPhase.ringing;
    _emit();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (isClosed || phase == CallPhase.ended) return;
    phase = CallPhase.connected;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      seconds++;
      _emit();
    });
    _emit();
  }

  void toggleMute() {
    muted = !muted;
    _emit();
  }

  void toggleSpeaker() {
    speakerOn = !speakerOn;
    _emit();
  }

  void toggleVideo() {
    videoOn = !videoOn;
    _emit();
  }

  void switchCamera() {
    frontCamera = !frontCamera;
    _emit();
  }

  void end() {
    phase = CallPhase.ended;
    _timer?.cancel();
    _emit();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
