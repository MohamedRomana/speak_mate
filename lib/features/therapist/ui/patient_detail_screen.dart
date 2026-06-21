import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/colors.dart';
import '../../../core/helper/extentions.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../gen/fonts.gen.dart';
import '../../../generated/locale_keys.g.dart';
import '../../shared/plans/ui/assign_plan_sheet.dart';
import '../../users/patient/dashboard/ui/widgets/progress_chart.dart';
import '../data/models/therapist_patient.dart';

/// ملف المريض للأخصائي — تقدّم + أصوات ضعيفة + تسجيلات + تقرير AI + تعيين خطة.
class PatientDetailScreen extends StatelessWidget {
  final TherapistPatient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final color = patient.isChild ? AppColors.primary : AppColors.secondary;
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
          text: LocaleKeys.patientProfile.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeSlideIn(child: _Header(patient: patient, color: color)),
            SizedBox(height: 16.h),
            _Card(
              title: LocaleKeys.progressOverview.tr(),
              icon: Icons.show_chart_rounded,
              child: Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: ProgressChart(series: patient.accuracySeries),
              ),
            ),
            SizedBox(height: 16.h),
            if (patient.weakSounds.isNotEmpty) ...[
              _Card(
                title: LocaleKeys.weakSounds.tr(),
                icon: Icons.warning_amber_rounded,
                child: Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: patient.weakSounds.map(_WeakSoundTile.new).toList(),
                ),
              ),
              SizedBox(height: 16.h),
            ],
            _Card(
              title: LocaleKeys.recordingsReview.tr(),
              icon: Icons.mic_none_rounded,
              child: patient.recordings.isEmpty
                  ? AppText(
                      text: LocaleKeys.noRecordings.tr(),
                      size: 13.sp,
                      color: AppColors.secondaryText,
                    )
                  : Column(
                      children: patient.recordings
                          .map((r) => _RecordingRow(rec: r))
                          .toList(),
                    ),
            ),
            SizedBox(height: 16.h),
            _AiReportCard(),
            SizedBox(height: 22.h),
            PrimaryButton(
              text: LocaleKeys.assignPlan.tr(),
              icon: Icons.assignment_add,
              onPressed: () => showAssignPlanSheet(context, patient.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TherapistPatient patient;
  final Color color;
  const _Header({required this.patient, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: color.withValues(alpha: 0.16),
            child: AppText(
              text: patient.name.isNotEmpty ? patient.name[0] : '?',
              size: 24.sp,
              family: FontFamily.tajawalBold,
              color: color,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: patient.name,
                  size: 18.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.mainText,
                ),
                SizedBox(height: 4.h),
                AppText(
                  text:
                      '${(patient.isChild ? LocaleKeys.condChild : LocaleKeys.condAdult).tr()} • ${patient.age}',
                  size: 12.sp,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          Column(
            children: [
              AppText(
                text: '${patient.accuracy}%',
                size: 22.sp,
                family: FontFamily.tajawalBold,
                color: color,
              ),
              AppText(
                text: LocaleKeys.statAccuracy.tr(),
                size: 9.sp,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordingRow extends StatelessWidget {
  final PatientRecording rec;
  const _RecordingRow({required this.rec});

  @override
  Widget build(BuildContext context) {
    final scoreColor = rec.accuracy >= 80
        ? AppColors.success
        : (rec.accuracy >= 60 ? AppColors.warning : AppColors.error);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.play_arrow_rounded,
                color: AppColors.primary, size: 24.w),
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
                  text: '${rec.durationLabel} • ${rec.dateLabel}',
                  size: 10.sp,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: AppText(
              text: '${rec.accuracy}%',
              size: 12.sp,
              family: FontFamily.tajawalBold,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiReportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.14),
            AppColors.secondary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  size: 20.w, color: AppColors.primary),
              SizedBox(width: 8.w),
              AppText(
                text: LocaleKeys.aiReport.tr(),
                size: 15.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          AppText(
            text: LocaleKeys.aiSummaryText.tr(),
            size: 13.sp,
            lines: 5,
            overflow: TextOverflow.visible,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _Card({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.w, color: AppColors.primary),
              SizedBox(width: 8.w),
              AppText(
                text: title,
                size: 15.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

/// رقاقة صوت ضعيف بلون حراري حسب نسبة الخطأ (كهرماني → أحمر).
class _WeakSoundTile extends StatelessWidget {
  final WeakSoundStat stat;
  const _WeakSoundTile(this.stat);

  @override
  Widget build(BuildContext context) {
    final t = stat.errorRate.clamp(0.0, 1.0);
    final color = Color.lerp(AppColors.warning, AppColors.error, t)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12 + t * 0.12),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: stat.sound,
            size: 18.sp,
            family: FontFamily.tajawalBold,
            color: color,
          ),
          SizedBox(width: 7.w),
          AppText(
            text: '${(t * 100).round()}%',
            size: 12.sp,
            family: FontFamily.tajawalMedium,
            color: color,
          ),
        ],
      ),
    );
  }
}
