import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/constants/colors.dart';
import '../../../core/helper/extentions.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/services/phoneme_analyzer.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/phoneme_breakdown.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../gen/fonts.gen.dart';
import '../../../generated/locale_keys.g.dart';
import '../data/models/rehab_models.dart';
import '../logic/rehab_session_cubit.dart';

/// شاشة جلسة إعادة التأهيل (كلام بطيء / نطق / لغة / ذاكرة).
class RehabSessionScreen extends StatelessWidget {
  final RehabModule module;
  const RehabSessionScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: BlocBuilder<RehabSessionCubit, int>(
          builder: (context, _) {
            final cubit = context.read<RehabSessionCubit>();
            if (cubit.phase == RehabPhase.finished) {
              return _Finished(cubit: cubit, module: module);
            }
            return Column(
              children: [
                _TopBar(cubit: cubit, module: module),
                Expanded(child: _Body(cubit: cubit, module: module)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final RehabSessionCubit cubit;
  final RehabModule module;
  const _TopBar({required this.cubit, required this.module});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.pop(),
            child: Icon(Icons.close_rounded, size: 26.w, color: AppColors.mainText),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 9.h,
              percent: cubit.progress.clamp(0, 1),
              backgroundColor: AppColors.border,
              progressColor: module.color,
              barRadius: Radius.circular(10.r),
              animation: true,
              animateFromLastPercent: true,
            ),
          ),
          SizedBox(width: 12.w),
          AppText(
            text: '${cubit.index + 1}/${cubit.phrases.length}',
            size: 13.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final RehabSessionCubit cubit;
  final RehabModule module;
  const _Body({required this.cubit, required this.module});

  @override
  Widget build(BuildContext context) {
    if (cubit.phase == RehabPhase.result) {
      return _Result(cubit: cubit, module: module);
    }
    final recording = cubit.phase == RehabPhase.recording;
    final checking = cubit.phase == RehabPhase.checking;
    final hidden = module.isMemory && !cubit.revealed;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          AppText(
            text: module.isMemory
                ? LocaleKeys.rememberThenSay.tr()
                : module.isSlow
                    ? LocaleKeys.listenCarefully.tr()
                    : LocaleKeys.nowRepeatClearly.tr(),
            size: 14.sp,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 18.h),
          // بطاقة العبارة (تُخفى في تمارين الذاكرة).
          Container(
            key: ValueKey('p${cubit.index}_$hidden'),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 34.h, horizontal: 16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  module.color.withValues(alpha: 0.14),
                  module.color.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: module.color.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: hidden
                ? Icon(Icons.visibility_off_rounded,
                    size: 48.w, color: module.color)
                : FadeSlideIn(
                    key: ValueKey('t${cubit.index}'),
                    from: SlideFrom.none,
                    beginScale: 0.9,
                    child: AppText(
                      text: cubit.current.text,
                      size: 28.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.mainText,
                      textAlign: TextAlign.center,
                      lines: 3,
                      overflow: TextOverflow.visible,
                    ),
                  ),
          ),
          SizedBox(height: 24.h),
          if (module.isSlow)
            _ListenButton(
              listening: cubit.phase == RehabPhase.listening,
              color: module.color,
              onTap: cubit.listenSlow,
            ),
          if (module.isSlow) SizedBox(height: 20.h),
          _RecordButton(
            recording: recording,
            color: module.color,
            enabled: !checking && cubit.phase != RehabPhase.listening,
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
                    : LocaleKeys.tapToRecord.tr(),
            size: 13.sp,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

class _ListenButton extends StatelessWidget {
  final bool listening;
  final Color color;
  final VoidCallback onTap;
  const _ListenButton({
    required this.listening,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              listening ? Icons.graphic_eq_rounded : Icons.slow_motion_video_rounded,
              color: color,
              size: 22.w,
            ),
            SizedBox(width: 8.w),
            AppText(
              text: LocaleKeys.slowMode.tr(),
              size: 14.sp,
              family: FontFamily.tajawalBold,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordButton extends StatefulWidget {
  final bool recording;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;
  const _RecordButton({
    required this.recording,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<_RecordButton>
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
            width: 92.w,
            height: 92.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: widget.recording
                    ? [AppColors.error, const Color(0xffDC2626)]
                    : [widget.color, widget.color.withValues(alpha: 0.7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.recording ? AppColors.error : widget.color)
                      .withValues(alpha: 0.3 + glow * 0.3),
                  blurRadius: 22 + glow * 16,
                  spreadRadius: glow * 6,
                ),
              ],
            ),
            child: Icon(
              widget.recording ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 38.w,
            ),
          );
        },
      ),
    );
  }
}

class _Result extends StatelessWidget {
  final RehabSessionCubit cubit;
  final RehabModule module;
  const _Result({required this.cubit, required this.module});

  @override
  Widget build(BuildContext context) {
    final color = cubit.correct ? AppColors.success : AppColors.warning;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          CircularPercentIndicator(
            radius: 54.r,
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
                  size: 26.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.mainText,
                ),
                AppText(text: '/100', size: 11.sp, color: AppColors.secondaryText),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          AppText(
            text: cubit.correct
                ? LocaleKeys.accuratePronunciation.tr()
                : LocaleKeys.needsImprovement.tr(),
            size: 17.sp,
            family: FontFamily.tajawalBold,
            color: color,
            textAlign: TextAlign.center,
            lines: 2,
          ),
          if (cubit.recognized.trim().isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text:
                        '🎙️ ${LocaleKeys.youSaid.tr()}: ${cubit.recognized}\n✅ ${LocaleKeys.correctLabel.tr()}: ${cubit.current.text}',
                    size: 13.sp,
                    lines: 4,
                    overflow: TextOverflow.visible,
                    color: AppColors.secondaryText,
                  ),
                  if (cubit.analysis != null) ...[
                    SizedBox(height: 12.h),
                    PhonemeBreakdown(analysis: cubit.analysis!),
                    SizedBox(height: 10.h),
                    // ملاحظة إكلينيكية موجّهة للبالغ.
                    AppText(
                      text: cubit.analysis!.feedback(SpeechAudience.adult),
                      size: 12.sp,
                      lines: 4,
                      overflow: TextOverflow.visible,
                      color: AppColors.mainText,
                    ),
                  ],
                ],
              ),
            ),
          ],
          SizedBox(height: 22.h),
          Row(
            children: [
              if (!cubit.correct) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: cubit.retry,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: module.color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: AppText(
                      text: LocaleKeys.tryAgain.tr(),
                      color: module.color,
                      family: FontFamily.tajawalBold,
                      size: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: PrimaryButton(
                  text: (cubit.isLast ? LocaleKeys.finish : LocaleKeys.next).tr(),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: cubit.next,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Finished extends StatelessWidget {
  final RehabSessionCubit cubit;
  final RehabModule module;
  const _Finished({required this.cubit, required this.module});

  @override
  Widget build(BuildContext context) {
    final avg = cubit.phrases.isEmpty ? 0 : (cubit.totalScore ~/ cubit.phrases.length);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: module.color.withValues(alpha: 0.15),
              ),
              child: Icon(Icons.verified_rounded, size: 56.w, color: module.color),
            ),
            SizedBox(height: 20.h),
            AppText(
              text: LocaleKeys.trainingComplete.tr(),
              size: 21.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.mainText,
              textAlign: TextAlign.center,
              lines: 2,
            ),
            SizedBox(height: 8.h),
            AppText(
              text: '${LocaleKeys.avgAccuracyLabel.tr()}: $avg%',
              size: 15.sp,
              color: AppColors.secondaryText,
            ),
            SizedBox(height: 30.h),
            PrimaryButton(
              text: LocaleKeys.backToHome.tr(),
              icon: Icons.home_rounded,
              onPressed: () => context.pop(),
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: cubit.restart,
              child: AppText(
                text: LocaleKeys.playAgain.tr(),
                size: 14.sp,
                color: AppColors.secondaryText,
                family: FontFamily.tajawalMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
