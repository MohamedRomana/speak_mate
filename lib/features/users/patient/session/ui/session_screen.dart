import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/helper/extentions.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../core/widgets/fade_slide_in.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../dashboard/data/models/session_model.dart';
import '../../exercises/ui/widgets/confetti_overlay.dart';
import '../logic/session_cubit.dart';

/// شاشة الجلسة الموجّهة المباشرة.
class SessionScreen extends StatelessWidget {
  final SessionModel session;
  const SessionScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: BlocBuilder<SessionCubit, int>(
          builder: (context, _) {
            final cubit = context.read<SessionCubit>();
            switch (cubit.phase) {
              case SessionPhase.connecting:
                return _Connecting(session: session);
              case SessionPhase.intro:
                return _Intro(session: session, cubit: cubit);
              case SessionPhase.finished:
                return _Finished(cubit: cubit);
              case SessionPhase.active:
              case SessionPhase.recording:
                return _Active(session: session, cubit: cubit);
            }
          },
        ),
      ),
    );
  }
}

class _TherapistAvatar extends StatelessWidget {
  final double size;
  const _TherapistAvatar({this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [AppColors.secondary, AppColors.primary]),
      ),
      child: Icon(Icons.medical_services_rounded,
          color: Colors.white, size: size.w * 0.5),
    );
  }
}

class _Connecting extends StatelessWidget {
  final SessionModel session;
  const _Connecting({required this.session});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingAvatar(),
          SizedBox(height: 24.h),
          AppText(
            text: session.therapistName,
            size: 18.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.mainText,
          ),
          SizedBox(height: 8.h),
          AppText(
            text: LocaleKeys.sessionConnecting.tr(),
            size: 13.sp,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: 26.w,
            height: 26.w,
            child: const CircularProgressIndicator(
                strokeWidth: 2.4, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _PulsingAvatar extends StatefulWidget {
  @override
  State<_PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<_PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return SizedBox(
          width: 160.w,
          height: 160.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 2; i++)
                Builder(builder: (_) {
                  final t = ((_c.value + i * 0.5) % 1.0);
                  return Container(
                    width: (100 + t * 60).w,
                    height: (100 + t * 60).w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: (1 - t) * 0.25),
                    ),
                  );
                }),
              child!,
            ],
          ),
        );
      },
      child: const _TherapistAvatar(),
    );
  }
}

class _Intro extends StatelessWidget {
  final SessionModel session;
  final SessionCubit cubit;
  const _Intro({required this.session, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FadeSlideIn(from: SlideFrom.none, child: _TherapistAvatar()),
          SizedBox(height: 16.h),
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: AppText(
              text: session.title,
              size: 19.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.mainText,
              textAlign: TextAlign.center,
              lines: 2,
            ),
          ),
          SizedBox(height: 16.h),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.border),
              ),
              child: AppText(
                text: LocaleKeys.sessionIntroMsg.tr(),
                size: 14.sp,
                lines: 4,
                textAlign: TextAlign.center,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          SizedBox(height: 28.h),
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: PrimaryButton(
              text: LocaleKeys.startSession.tr(),
              icon: Icons.play_arrow_rounded,
              onPressed: cubit.beginActivities,
            ),
          ),
        ],
      ),
    );
  }
}

class _Active extends StatelessWidget {
  final SessionModel session;
  final SessionCubit cubit;
  const _Active({required this.session, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final step = cubit.current;
    return Column(
      children: [
        _ActiveTopBar(session: session, cubit: cubit),
        Expanded(
          child: step.kind == SessionStepKind.tip
              ? _TipStep(cubit: cubit)
              : _RepeatStep(cubit: cubit),
        ),
      ],
    );
  }
}

class _ActiveTopBar extends StatelessWidget {
  final SessionModel session;
  final SessionCubit cubit;
  const _ActiveTopBar({required this.session, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _TherapistAvatar(size: 42),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: session.therapistName,
                      size: 14.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.mainText,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: const BoxDecoration(
                              color: AppColors.error, shape: BoxShape.circle),
                        ),
                        SizedBox(width: 5.w),
                        AppText(
                          text: LocaleKeys.sessionLive.tr(),
                          size: 11.sp,
                          color: AppColors.error,
                          family: FontFamily.tajawalMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 14.w, color: AppColors.secondaryText),
                    SizedBox(width: 4.w),
                    AppText(
                      text: cubit.durationLabel,
                      size: 12.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.mainText,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              InkWell(
                onTap: () => context.pop(),
                child: Icon(Icons.close_rounded,
                    size: 24.w, color: AppColors.secondaryText),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 8.h,
            percent: cubit.progress.clamp(0, 1),
            backgroundColor: AppColors.border,
            progressColor: AppColors.primary,
            barRadius: Radius.circular(8.r),
            animation: true,
            animateFromLastPercent: true,
          ),
        ],
      ),
    );
  }
}

class _RepeatStep extends StatelessWidget {
  final SessionCubit cubit;
  const _RepeatStep({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final step = cubit.current;
    final recording = cubit.phase == SessionPhase.recording;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: '${LocaleKeys.sessionStep.tr()} ${cubit.index + 1}/${cubit.steps.length}',
            size: 13.sp,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 20.h),
          FadeSlideIn(
            key: ValueKey('w${cubit.index}'),
            from: SlideFrom.none,
            beginScale: 0.85,
            child: Column(
              children: [
                Text(step.emoji, style: TextStyle(fontSize: 72.sp)),
                SizedBox(height: 12.h),
                AppText(
                  text: step.word,
                  size: 32.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.mainText,
                ),
              ],
            ),
          ),
          SizedBox(height: 36.h),
          GestureDetector(
            onTap: recording
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    cubit.recordStep();
                  },
            child: _RecordCircle(recording: recording),
          ),
          SizedBox(height: 14.h),
          AppText(
            text: recording
                ? LocaleKeys.recording.tr()
                : LocaleKeys.sessionRecordHint.tr(),
            size: 13.sp,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

class _RecordCircle extends StatefulWidget {
  final bool recording;
  const _RecordCircle({required this.recording});

  @override
  State<_RecordCircle> createState() => _RecordCircleState();
}

class _RecordCircleState extends State<_RecordCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _p = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _p,
      builder: (context, child) {
        final glow = widget.recording ? _p.value : 0.0;
        return Container(
          width: 92.w,
          height: 92.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: widget.recording
                  ? [AppColors.error, const Color(0xffD94A4A)]
                  : [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.recording ? AppColors.error : AppColors.primary)
                    .withValues(alpha: 0.3 + glow * 0.3),
                blurRadius: 22 + glow * 16,
                spreadRadius: glow * 6,
              ),
            ],
          ),
          child: Icon(
            widget.recording ? Icons.graphic_eq_rounded : Icons.mic_rounded,
            color: Colors.white,
            size: 38.w,
          ),
        );
      },
    );
  }
}

class _TipStep extends StatelessWidget {
  final SessionCubit cubit;
  const _TipStep({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90.w,
            height: 90.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.warning.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.lightbulb_rounded,
                color: AppColors.warning, size: 44.w),
          ),
          SizedBox(height: 16.h),
          AppText(
            text: LocaleKeys.sessionTip.tr(),
            size: 16.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.warning,
          ),
          SizedBox(height: 10.h),
          AppText(
            text: cubit.current.tipKey.tr(),
            size: 15.sp,
            lines: 4,
            textAlign: TextAlign.center,
            color: AppColors.mainText,
          ),
          SizedBox(height: 28.h),
          PrimaryButton(
            text: LocaleKeys.continueWord.tr(),
            icon: Icons.arrow_forward_rounded,
            onPressed: cubit.continueTip,
          ),
        ],
      ),
    );
  }
}

class _Finished extends StatelessWidget {
  final SessionCubit cubit;
  const _Finished({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeSlideIn(
                  from: SlideFrom.none,
                  beginScale: 0.7,
                  child: Text('🎉', style: TextStyle(fontSize: 76.sp)),
                ),
                SizedBox(height: 16.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 150),
                  child: AppText(
                    text: LocaleKeys.sessionDoneTitle.tr(),
                    size: 21.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                    textAlign: TextAlign.center,
                    lines: 2,
                  ),
                ),
                SizedBox(height: 20.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 250),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Stat(
                        icon: Icons.timer_outlined,
                        value: cubit.durationLabel,
                        label: LocaleKeys.sessionDuration.tr(),
                      ),
                      SizedBox(width: 16.w),
                      _Stat(
                        icon: Icons.check_circle_rounded,
                        value: '${cubit.completedSteps}',
                        label: LocaleKeys.stepsCompleted.tr(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 350),
                  child: PrimaryButton(
                    text: LocaleKeys.backToHome.tr(),
                    icon: Icons.home_rounded,
                    onPressed: () => context.pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned.fill(child: ConfettiOverlay()),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24.w),
          SizedBox(height: 6.h),
          AppText(
            text: value,
            size: 18.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.mainText,
          ),
          AppText(text: label, size: 10.sp, color: AppColors.secondaryText),
        ],
      ),
    );
  }
}
