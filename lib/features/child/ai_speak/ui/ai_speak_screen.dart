import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../shared/gamification/logic/gamification_cubit.dart';
import '../../../users/patient/exercises/ui/widgets/confetti_overlay.dart';
import '../../../users/patient/exercises/ui/widgets/star_rating.dart';
import '../logic/ai_speak_cubit.dart';

/// شاشة "تحدّث مع AI" — نطق فوري وتصحيح بالذكاء الاصطناعي.
class AiSpeakScreen extends StatefulWidget {
  const AiSpeakScreen({super.key});

  @override
  State<AiSpeakScreen> createState() => _AiSpeakScreenState();
}

class _AiSpeakScreenState extends State<AiSpeakScreen> {
  bool _awarded = false;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AiSpeakCubit>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Transform.flip(
            flipX: context.locale.languageCode == 'ar',
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18.w, color: AppColors.mainText),
          ),
        ),
        title: AppText(
          text: LocaleKeys.aiSpeak.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AiSpeakCubit, int>(
        listener: (context, _) {
          if (cubit.phase == AiSpeakPhase.result && cubit.correct && !_awarded) {
            _awarded = true;
            context.read<GamificationCubit>().addXp(20);
            context.read<GamificationCubit>().bumpGoal('g_ai');
          }
          if (cubit.phase == AiSpeakPhase.prompt) _awarded = false;
        },
        builder: (context, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  children: [
                    AppText(
                      text: LocaleKeys.sayThisWord.tr(),
                      size: 14.sp,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(height: 16.h),
                    _WordCard(cubit: cubit),
                    SizedBox(height: 28.h),
                    if (cubit.phase == AiSpeakPhase.result)
                      _Result(cubit: cubit)
                    else
                      _RecordArea(cubit: cubit),
                  ],
                ),
              ),
              if (cubit.phase == AiSpeakPhase.result && cubit.score >= 85)
                const Positioned.fill(child: ConfettiOverlay()),
            ],
          );
        },
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final AiSpeakCubit cubit;
  const _WordCard({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      key: ValueKey('w${cubit.index}'),
      from: SlideFrom.none,
      beginScale: 0.88,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 30.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.16),
              AppColors.secondary.withValues(alpha: 0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(cubit.current.emoji, style: TextStyle(fontSize: 72.sp)),
            SizedBox(height: 10.h),
            AppText(
              text: cubit.current.text,
              size: 32.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.mainText,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordArea extends StatelessWidget {
  final AiSpeakCubit cubit;
  const _RecordArea({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final recording = cubit.phase == AiSpeakPhase.recording;
    final checking = cubit.phase == AiSpeakPhase.checking;
    return Column(
      children: [
        _MicButton(
          recording: recording,
          enabled: !checking,
          onTap: () {
            HapticFeedback.mediumImpact();
            recording ? cubit.stopRecording() : cubit.startRecording();
          },
        ),
        SizedBox(height: 14.h),
        AppText(
          text: checking
              ? LocaleKeys.checking.tr()
              : recording
                  ? LocaleKeys.tapToStop.tr()
                  : LocaleKeys.aiSpeakDesc.tr(),
          size: 13.sp,
          lines: 2,
          textAlign: TextAlign.center,
          color: AppColors.secondaryText,
        ),
      ],
    );
  }
}

class _MicButton extends StatefulWidget {
  final bool recording;
  final bool enabled;
  final VoidCallback onTap;
  const _MicButton({
    required this.recording,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<_MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _p = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _p,
        builder: (context, _) {
          final glow = widget.recording ? _p.value : 0.0;
          return Container(
            width: 104.w,
            height: 104.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: widget.recording
                    ? [AppColors.error, const Color(0xffDC2626)]
                    : [AppColors.primary, AppColors.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.recording ? AppColors.error : AppColors.primary)
                      .withValues(alpha: 0.35 + glow * 0.3),
                  blurRadius: 26 + glow * 18,
                  spreadRadius: glow * 8,
                ),
              ],
            ),
            child: Icon(
              widget.recording ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 44.w,
            ),
          );
        },
      ),
    );
  }
}

class _Result extends StatelessWidget {
  final AiSpeakCubit cubit;
  const _Result({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final color = cubit.correct ? AppColors.success : AppColors.warning;
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 56.r,
          lineWidth: 9.w,
          percent: (cubit.score / 100).clamp(0, 1),
          animation: true,
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: AppColors.border,
          progressColor: color,
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: '${cubit.score}',
                size: 28.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
              ),
              AppText(text: '/100', size: 11.sp, color: AppColors.secondaryText),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        if (cubit.correct) ...[
          StarRating(stars: cubit.score >= 90 ? 3 : 2),
          SizedBox(height: 10.h),
          AppText(
            text: LocaleKeys.excellent.tr(),
            size: 20.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.success,
          ),
        ] else ...[
          AppText(
            text: LocaleKeys.tryAgain.tr(),
            size: 20.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.warning,
          ),
        ],
        SizedBox(height: 14.h),
        _FeedbackCard(cubit: cubit),
        SizedBox(height: 22.h),
        Row(
          children: [
            if (!cubit.correct) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: cubit.retry,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: AppText(
                    text: LocaleKeys.tryAgain.tr(),
                    color: AppColors.primary,
                    family: FontFamily.tajawalBold,
                    size: 14.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: PrimaryButton(
                text: LocaleKeys.newWord.tr(),
                icon: Icons.arrow_forward_rounded,
                onPressed: cubit.next,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final AiSpeakCubit cubit;
  const _FeedbackCard({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cubit.recognized.trim().isNotEmpty)
            _row('🎙️', '${LocaleKeys.youSaid.tr()}: ${cubit.recognized}',
                AppColors.secondaryText),
          if (!cubit.correct) ...[
            SizedBox(height: 6.h),
            _row('✅', '${LocaleKeys.correctLabel.tr()}: ${cubit.current.text}',
                AppColors.success),
            if (cubit.focus.isNotEmpty) ...[
              SizedBox(height: 6.h),
              _row('👉', '${LocaleKeys.focusOnSound.tr()} "${cubit.focus}"',
                  AppColors.warning),
            ],
          ],
        ],
      ),
    );
  }

  Widget _row(String emoji, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: TextStyle(fontSize: 14.sp)),
        SizedBox(width: 8.w),
        Expanded(
          child: AppText(
            text: text,
            size: 13.sp,
            lines: 2,
            overflow: TextOverflow.visible,
            color: color,
          ),
        ),
      ],
    );
  }
}
