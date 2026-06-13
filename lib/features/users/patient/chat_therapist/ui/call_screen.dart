import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/helper/extentions.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../logic/call_cubit.dart';

/// شاشة مكالمة (صوتية/فيديو). الفيديو يعرض الكاميرا الأمامية الحقيقية كـ self-view.
class CallScreen extends StatefulWidget {
  final String name;
  const CallScreen({super.key, required this.name});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  CameraController? _cam;
  bool _camReady = false;
  bool _switching = false;
  List<CameraDescription> _cameras = const [];

  @override
  void initState() {
    super.initState();
    if (context.read<CallCubit>().isVideo) {
      _initCamera(front: true);
    }
  }

  Future<void> _initCamera({required bool front}) async {
    if (_switching) return; // منع التهيئة المتزامنة
    _switching = true;
    try {
      if (_cameras.isEmpty) _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _switching = false;
        return;
      }
      final desc = _cameras.firstWhere(
        (c) =>
            c.lensDirection ==
            (front ? CameraLensDirection.front : CameraLensDirection.back),
        orElse: () => _cameras.first,
      );

      // مهم: نتخلّص من الكاميرا القديمة أولاً (لا يمكن فتح كاميرتين معاً) ثم نهيّئ
      // الجديدة — وإلا تفشل التهيئة ويتجمّد العرض.
      final old = _cam;
      _cam = null;
      if (mounted) setState(() => _camReady = false);
      await old?.dispose();

      final controller = CameraController(
        desc,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        _switching = false;
        return;
      }
      setState(() {
        _cam = controller;
        _camReady = true;
      });
    } catch (_) {
      if (mounted) setState(() => _camReady = false);
    } finally {
      _switching = false;
    }
  }

  @override
  void dispose() {
    _cam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CallCubit>();
    return Scaffold(
      backgroundColor: const Color(0xff0E1726),
      body: BlocConsumer<CallCubit, int>(
        listener: (context, _) {
          if (cubit.phase == CallPhase.ended) {
            Future.delayed(const Duration(milliseconds: 250), () {
              if (context.mounted) context.pop();
            });
          }
        },
        builder: (context, _) {
          final connected = cubit.phase == CallPhase.connected;
          final showVideo = cubit.isVideo && cubit.videoOn;
          return Stack(
            children: [
              // الخلفية / الطرف الآخر.
              Positioned.fill(child: _RemoteView(name: widget.name)),

              // self-view (الكاميرا الأمامية) في مكالمة الفيديو.
              if (showVideo)
                PositionedDirectional(
                  top: 50.h,
                  end: 16.w,
                  child: _SelfView(cam: _cam, ready: _camReady),
                ),

              // معلومات علوية.
              Positioned(
                top: 60.h,
                left: 0,
                right: 0,
                child: _TopInfo(
                  name: widget.name,
                  status: connected
                      ? cubit.durationLabel
                      : (cubit.phase == CallPhase.ringing
                          ? LocaleKeys.ringing.tr()
                          : LocaleKeys.calling.tr()),
                  subtitle: (cubit.isVideo
                          ? LocaleKeys.videoCall
                          : LocaleKeys.voiceCall)
                      .tr(),
                ),
              ),

              // أزرار التحكّم السفلية.
              Positioned(
                left: 0,
                right: 0,
                bottom: 50.h,
                child: _Controls(cubit: cubit, onSwitch: _switchCamera),
              ),
            ],
          );
        },
      ),
    );
  }

  void _switchCamera() {
    context.read<CallCubit>().switchCamera();
    _initCamera(front: context.read<CallCubit>().frontCamera);
  }
}

class _RemoteView extends StatelessWidget {
  final String name;
  const _RemoteView({required this.name});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff1B2E52), Color(0xff0E1726)],
        ),
      ),
      child: Center(
        child: Container(
          width: 140.w,
          height: 140.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.primary]),
          ),
          child: Icon(Icons.medical_services_rounded,
              color: Colors.white, size: 70.w),
        ),
      ),
    );
  }
}

class _SelfView extends StatelessWidget {
  final CameraController? cam;
  final bool ready;
  const _SelfView({required this.cam, required this.ready});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 110.w,
        height: 150.h,
        color: Colors.black,
        child: ready && cam != null && cam!.value.isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: cam!.value.previewSize?.height ?? 110.w,
                  height: cam!.value.previewSize?.width ?? 150.h,
                  child: CameraPreview(cam!),
                ),
              )
            : Center(
                child: Icon(Icons.videocam_off_rounded,
                    color: Colors.white54, size: 30.w),
              ),
      ),
    );
  }
}

class _TopInfo extends StatelessWidget {
  final String name;
  final String status;
  final String subtitle;
  const _TopInfo({
    required this.name,
    required this.status,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 24.sp,
            color: Colors.white,
            fontFamily: FontFamily.tajawalBold,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          status,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.accent,
            fontFamily: FontFamily.tajawalMedium,
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  final CallCubit cubit;
  final VoidCallback onSwitch;
  const _Controls({required this.cubit, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CallBtn(
          icon: cubit.muted ? Icons.mic_off_rounded : Icons.mic_rounded,
          label: cubit.muted ? LocaleKeys.unmute.tr() : LocaleKeys.mute.tr(),
          active: cubit.muted,
          onTap: cubit.toggleMute,
        ),
        SizedBox(width: 18.w),
        if (cubit.isVideo) ...[
          _CallBtn(
            icon: cubit.videoOn
                ? Icons.videocam_rounded
                : Icons.videocam_off_rounded,
            label: LocaleKeys.cameraLabel.tr(),
            active: !cubit.videoOn,
            onTap: cubit.toggleVideo,
          ),
          SizedBox(width: 18.w),
          _CallBtn(
            icon: Icons.cameraswitch_rounded,
            label: LocaleKeys.flipCamera.tr(),
            onTap: onSwitch,
          ),
        ] else ...[
          _CallBtn(
            icon: cubit.speakerOn
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            label: LocaleKeys.speaker.tr(),
            active: cubit.speakerOn,
            onTap: cubit.toggleSpeaker,
          ),
        ],
        SizedBox(width: 18.w),
        _CallBtn(
          icon: Icons.call_end_rounded,
          label: LocaleKeys.endCall.tr(),
          color: AppColors.error,
          filled: true,
          onTap: cubit.end,
        ),
      ],
    );
  }
}

class _CallBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool filled;
  final Color? color;

  const _CallBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.filled = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? (color ?? AppColors.error)
        : (active ? Colors.white : Colors.white.withValues(alpha: 0.18));
    final fg = filled ? Colors.white : (active ? AppColors.primary : Colors.white);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: fg, size: 28.w),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
