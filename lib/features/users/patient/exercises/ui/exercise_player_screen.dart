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
import '../data/models/exercise_models.dart';
import '../logic/exercise_player_cubit.dart';
import 'category_visuals.dart';
import 'widgets/confetti_overlay.dart';
import 'widgets/star_rating.dart';

/// شاشة مشغّل التمارين التفاعلي.
class ExercisePlayerScreen extends StatelessWidget {
  const ExercisePlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: BlocBuilder<ExercisePlayerCubit, int>(
          builder: (context, _) {
            final cubit = context.read<ExercisePlayerCubit>();
            final phase = cubit.phase;
            if (phase == PlayerPhase.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (phase == PlayerPhase.error || cubit.items.isEmpty) {
              return Center(
                child: AppText(
                  text: LocaleKeys.noUpcomingSessions.tr(),
                  color: AppColors.secondaryText,
                ),
              );
            }
            if (phase == PlayerPhase.finished) {
              return _FinishedView(cubit: cubit);
            }
            return Column(
              children: [
                _PlayerTopBar(cubit: cubit),
                Expanded(
                  child: _ExerciseBody(cubit: cubit, phase: phase),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlayerTopBar extends StatelessWidget {
  final ExercisePlayerCubit cubit;
  const _PlayerTopBar({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(20.r),
            child: Icon(Icons.close_rounded, size: 26.w, color: AppColors.mainText),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 10.h,
              percent: cubit.progress.clamp(0, 1),
              backgroundColor: AppColors.border,
              progressColor: cubit.category.color,
              barRadius: Radius.circular(10.r),
              animation: true,
              animateFromLastPercent: true,
            ),
          ),
          SizedBox(width: 12.w),
          AppText(
            text: '${cubit.index + 1}/${cubit.items.length}',
            size: 13.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

class _ExerciseBody extends StatelessWidget {
  final ExercisePlayerCubit cubit;
  final PlayerPhase phase;
  const _ExerciseBody({required this.cubit, required this.phase});

  @override
  Widget build(BuildContext context) {
    final item = cubit.current;
    final isMatch = item.isMatchLike;
    final instruction = switch (item.kind) {
      ExerciseKind.match => LocaleKeys.whichImage,
      ExerciseKind.guess => LocaleKeys.listenAndGuess,
      ExerciseKind.pictureName => LocaleKeys.nameThisPicture,
      ExerciseKind.repeat => LocaleKeys.repeatAfterMe,
    };
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          _DifficultyBadge(difficulty: item.difficulty),
          SizedBox(height: 20.h),
          AppText(
            text: instruction.tr(),
            size: 15.sp,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 16.h),
          _PromptCard(
            key: ValueKey('prompt_${item.id}'),
            item: item,
            color: cubit.category.color,
          ),
          SizedBox(height: 24.h),
          _ListenButton(
            listening: phase == PlayerPhase.listening,
            color: cubit.category.color,
            onTap: cubit.listen,
          ),
          SizedBox(height: 24.h),
          if (isMatch)
            _MatchOptions(cubit: cubit, phase: phase)
          else
            _RepeatControls(cubit: cubit, phase: phase),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final ExerciseDifficulty difficulty;
  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: difficulty.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AppText(
        text: '${LocaleKeys.level.tr()}: ${difficulty.labelKey.tr()}',
        size: 11.sp,
        color: difficulty.color,
        family: FontFamily.tajawalMedium,
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final ExerciseItem item;
  final Color color;
  const _PromptCard({super.key, required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      from: SlideFrom.none,
      beginScale: 0.85,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 28.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.14), color.withValues(alpha: 0.05)],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(item.emoji, style: TextStyle(fontSize: 64.sp)),
            SizedBox(height: 12.h),
            // تُخفى الكلمة في الحزر/تسمية الصورة (يظهر "؟" بدلاً منها).
            AppText(
              text: item.showsWord ? item.prompt : '؟',
              size: 28.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.mainText,
              textAlign: TextAlign.center,
              lines: 2,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
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
              listening ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
              color: color,
              size: 22.w,
            ),
            SizedBox(width: 8.w),
            AppText(
              text: (listening ? LocaleKeys.listen : LocaleKeys.listen).tr(),
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

/// عناصر تمرين التكرار: زر تسجيل + نتيجة بالنجوم.
class _RepeatControls extends StatelessWidget {
  final ExercisePlayerCubit cubit;
  final PlayerPhase phase;
  const _RepeatControls({required this.cubit, required this.phase});

  @override
  Widget build(BuildContext context) {
    if (phase == PlayerPhase.result) {
      return _ResultView(cubit: cubit);
    }
    final recording = phase == PlayerPhase.recording;
    final checking = phase == PlayerPhase.checking;
    return Column(
      children: [
        _RecordButton(
          recording: recording,
          enabled: !checking && phase != PlayerPhase.listening,
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
    );
  }
}

class _RecordButton extends StatefulWidget {
  final bool recording;
  final bool enabled;
  final VoidCallback onTap;
  const _RecordButton({
    required this.recording,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<_RecordButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final glow = widget.recording ? (0.5 + _pulse.value * 0.5) : 0.0;
          return Container(
            width: 96.w,
            height: 96.w,
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
                  blurRadius: 24 + glow * 16,
                  spreadRadius: glow * 6,
                ),
              ],
            ),
            child: Icon(
              widget.recording ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 40.w,
            ),
          );
        },
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final ExercisePlayerCubit cubit;
  const _ResultView({required this.cubit});

  @override
  Widget build(BuildContext context) {
    // إجابة خاطئة (لم يُتعرّف على النطق الصحيح) → حاول مرة أخرى.
    if (!cubit.lastCorrect) {
      return Column(
        children: [
          Icon(Icons.refresh_rounded, size: 48.w, color: AppColors.warning),
          SizedBox(height: 10.h),
          AppText(
            text: LocaleKeys.tryAgain.tr(),
            size: 20.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.warning,
          ),
          if (cubit.lastRecognized.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            AppText(
              text: '🎙️ "${cubit.lastRecognized}"',
              size: 13.sp,
              color: AppColors.secondaryText,
              textAlign: TextAlign.center,
              lines: 2,
            ),
          ],
          SizedBox(height: 22.h),
          PrimaryButton(
            text: LocaleKeys.tryAgain.tr(),
            icon: Icons.replay_rounded,
            onPressed: cubit.retryCurrent,
          ),
        ],
      );
    }
    return Column(
      children: [
        StarRating(stars: cubit.lastStars),
        SizedBox(height: 12.h),
        AppText(
          text: (cubit.lastStars >= 3 ? LocaleKeys.excellent : LocaleKeys.goodJob)
              .tr(),
          size: 20.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.success,
        ),
        SizedBox(height: 24.h),
        PrimaryButton(
          text: (cubit.isLast ? LocaleKeys.finish : LocaleKeys.next).tr(),
          icon: Icons.arrow_forward_rounded,
          onPressed: cubit.next,
        ),
      ],
    );
  }
}

/// خيارات تمرين المطابقة (شبكة رموز).
class _MatchOptions extends StatelessWidget {
  final ExercisePlayerCubit cubit;
  final PlayerPhase phase;
  const _MatchOptions({required this.cubit, required this.phase});

  @override
  Widget build(BuildContext context) {
    final item = cubit.current;
    final answered = phase == PlayerPhase.matchResult;
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 1.4,
          children: List.generate(item.options.length, (i) {
            final isCorrect = i == item.correctIndex;
            final isSelected = cubit.selectedOption == i;
            Color border = AppColors.border;
            Color bg = AppColors.card;
            if (answered) {
              if (isCorrect && cubit.matchCorrect) {
                border = AppColors.success;
                bg = AppColors.success.withValues(alpha: 0.12);
              } else if (isSelected && !cubit.matchCorrect) {
                border = AppColors.error;
                bg = AppColors.error.withValues(alpha: 0.12);
              }
            }
            return GestureDetector(
              onTap: cubit.matchCorrect
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      cubit.selectOption(i);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: border, width: 1.6),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.options[i],
                  style: TextStyle(fontSize: 44.sp),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 18.h),
        if (answered)
          cubit.matchCorrect
              ? Column(
                  children: [
                    AppText(
                      text: LocaleKeys.correct.tr(),
                      size: 18.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.success,
                    ),
                    SizedBox(height: 16.h),
                    PrimaryButton(
                      text: (cubit.isLast
                              ? LocaleKeys.finish
                              : LocaleKeys.next)
                          .tr(),
                      icon: Icons.arrow_forward_rounded,
                      onPressed: cubit.next,
                    ),
                  ],
                )
              : AppText(
                  text: LocaleKeys.wrong.tr(),
                  size: 15.sp,
                  family: FontFamily.tajawalMedium,
                  color: AppColors.error,
                ),
      ],
    );
  }
}

class _FinishedView extends StatelessWidget {
  final ExercisePlayerCubit cubit;
  const _FinishedView({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final pct = cubit.maxStars == 0
        ? 0
        : ((cubit.totalStars / cubit.maxStars) * 100).round();
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
                  child: Text('🎉', style: TextStyle(fontSize: 80.sp)),
                ),
                SizedBox(height: 16.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 150),
                  child: AppText(
                    text: LocaleKeys.exerciseComplete.tr(),
                    size: 22.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                    textAlign: TextAlign.center,
                    lines: 2,
                  ),
                ),
                SizedBox(height: 8.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 250),
                  child: AppText(
                    text: '${LocaleKeys.yourScore.tr()}: $pct%',
                    size: 16.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 16.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 350),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.warning, size: 28.w),
                      SizedBox(width: 6.w),
                      AppText(
                        text: '${cubit.totalStars}/${cubit.maxStars}',
                        size: 20.sp,
                        family: FontFamily.tajawalBold,
                        color: AppColors.mainText,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 450),
                  child: PrimaryButton(
                    text: LocaleKeys.playAgain.tr(),
                    icon: Icons.replay_rounded,
                    onPressed: cubit.restart,
                  ),
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () => context.pop(),
                  child: AppText(
                    text: LocaleKeys.backToExercises.tr(),
                    size: 14.sp,
                    color: AppColors.secondaryText,
                    family: FontFamily.tajawalMedium,
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
