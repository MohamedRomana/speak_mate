import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/logic/action_state.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../gen/fonts.gen.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../data/models/recording_model.dart';
import '../../logic/profile_cubit.dart';
import 'section_card.dart';

/// قسم التسجيلات الصوتية/الفيديو — رفع وعرض وحذف.
class RecordingsSection extends StatelessWidget {
  const RecordingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ActionState>(
      builder: (context, _) {
        final cubit = context.read<ProfileCubit>();
        final recordings = cubit.recordings;
        return SectionCard(
          title: LocaleKeys.recordings.tr(),
          icon: Icons.mic_none_rounded,
          trailing: Row(
            children: [
              _AddButton(
                icon: Icons.mic_rounded,
                onTap: () => cubit.addRecording(RecordingType.audio),
              ),
              SizedBox(width: 8.w),
              _AddButton(
                icon: Icons.videocam_rounded,
                onTap: () => cubit.addRecording(RecordingType.video),
              ),
            ],
          ),
          child: recordings.isEmpty
              ? _Empty()
              : Column(
                  children: [
                    for (var i = 0; i < recordings.length; i++)
                      _RecordingTile(
                        rec: recordings[i],
                        isLast: i == recordings.length - 1,
                        onDelete: () => cubit.deleteRecording(recordings[i].id),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _AddButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AddButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: AppColors.softPrimary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 18.w, color: AppColors.primary),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: AppText(
          text: LocaleKeys.noRecordings.tr(),
          size: 13.sp,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }
}

class _RecordingTile extends StatelessWidget {
  final Recording rec;
  final bool isLast;
  final VoidCallback onDelete;

  const _RecordingTile({
    required this.rec,
    required this.isLast,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAudio = rec.type == RecordingType.audio;
    final color = isAudio ? AppColors.primary : AppColors.secondary;
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isAudio ? Icons.graphic_eq_rounded : Icons.play_circle_outline_rounded,
              color: color,
              size: 22.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: rec.title,
                  size: 13.sp,
                  family: FontFamily.tajawalMedium,
                  color: AppColors.mainText,
                ),
                SizedBox(height: 2.h),
                AppText(
                  text:
                      '${isAudio ? LocaleKeys.audio.tr() : LocaleKeys.video.tr()} • ${rec.durationLabel} • ${rec.dateLabel}',
                  size: 11.sp,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20.w,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
