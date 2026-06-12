import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/helper/extentions.dart';
import '../../../../../core/logic/action_state.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../core/widgets/flash_message.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../dashboard/ui/widgets/progress_chart.dart';
import '../data/models/report_data.dart';
import '../logic/reports_cubit.dart';
import 'widgets/completion_bar_chart.dart';

/// شاشة التقارير والتقدّم — رسوم بيانية + ملخّص + تصدير.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ScreenshotController controller = ScreenshotController();

  @override
  Widget build(BuildContext context) {
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
          text: LocaleKeys.reportsTitle.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: LocaleKeys.exportReport.tr(),
            onPressed: () => _export(context, controller),
            icon: const Icon(Icons.ios_share_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: BlocBuilder<ReportsCubit, ActionState>(
        builder: (context, state) {
          final cubit = context.read<ReportsCubit>();
          final data = cubit.data;
          if (state is ActionLoading && data == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (data == null) return const SizedBox.shrink();
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PeriodToggle(cubit: cubit),
                SizedBox(height: 16.h),
                Screenshot(
                  controller: controller,
                  child: Container(
                    color: AppColors.scaffoldBg,
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SummaryGrid(data: data),
                        SizedBox(height: 16.h),
                        _ChartCard(
                          title: LocaleKeys.avgAccuracy.tr(),
                          icon: Icons.show_chart_rounded,
                          child: ProgressChart(series: data.accuracySeries),
                        ),
                        SizedBox(height: 16.h),
                        _ChartCard(
                          title: LocaleKeys.sessionCompletion.tr(),
                          icon: Icons.bar_chart_rounded,
                          child: CompletionBarChart(
                            series: data.completionSeries,
                            labels: data.axisLabels,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _SkillsCard(skills: data.skills),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    ScreenshotController controller,
  ) async {
    showFlashMessage(
      message: LocaleKeys.preparingReport.tr(),
      type: FlashMessageType.success,
      context: context,
    );
    // التقاط صورة منطقة التقرير ثم تضمينها في مستند PDF حقيقي.
    final bytes = await controller.capture(pixelRatio: 2.5);
    if (bytes == null) return;

    final doc = pw.Document();
    final image = pw.MemoryImage(bytes);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => pw.Center(
          child: pw.Image(image, fit: pw.BoxFit.contain),
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = await File(
      '${dir.path}/speakmate_report.pdf',
    ).writeAsBytes(await doc.save());
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        text: LocaleKeys.reportsTitle.tr(),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final ReportsCubit cubit;
  const _PeriodToggle({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _seg(LocaleKeys.periodWeek.tr(), ReportPeriod.week),
          _seg(LocaleKeys.periodMonth.tr(), ReportPeriod.month),
        ],
      ),
    );
  }

  Widget _seg(String label, ReportPeriod p) {
    final selected = cubit.period == p;
    return Expanded(
      child: GestureDetector(
        onTap: () => cubit.switchPeriod(p),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: AppText(
            text: label,
            size: 13.sp,
            family: FontFamily.tajawalBold,
            color: selected ? Colors.white : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final ReportData data;
  const _SummaryGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.event_available_rounded, '${data.totalSessions}',
          LocaleKeys.totalSessions.tr(), AppColors.primary),
      (Icons.fitness_center_rounded, '${data.totalExercises}',
          LocaleKeys.totalExercises.tr(), AppColors.secondary),
      (Icons.track_changes_rounded, '${data.avgAccuracy}%',
          LocaleKeys.avgAccuracy.tr(), AppColors.accent),
      (Icons.local_fire_department_rounded, '${data.streak}',
          LocaleKeys.statStreak.tr(), AppColors.warning),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 2.4,
      children: items
          .map((e) => _SummaryCard(
                icon: e.$1,
                value: e.$2,
                label: e.$3,
                color: e.$4,
              ))
          .toList(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: value,
                  size: 17.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.mainText,
                ),
                AppText(
                  text: label,
                  size: 10.sp,
                  lines: 1,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _ChartCard({
    required this.title,
    required this.icon,
    required this.child,
  });

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
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class _SkillsCard extends StatelessWidget {
  final List<SkillScore> skills;
  const _SkillsCard({required this.skills});

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
              Icon(Icons.insights_rounded, size: 20.w, color: AppColors.primary),
              SizedBox(width: 8.w),
              AppText(
                text: LocaleKeys.skillsImprovement.tr(),
                size: 15.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...skills.map((s) {
            final pct = (s.value * 100).round();
            return Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: s.labelKey.tr(),
                        size: 13.sp,
                        family: FontFamily.tajawalMedium,
                        color: AppColors.mainText,
                      ),
                      AppText(
                        text: '$pct%',
                        size: 12.sp,
                        family: FontFamily.tajawalBold,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    lineHeight: 8.h,
                    percent: s.value.clamp(0, 1),
                    backgroundColor: AppColors.border,
                    linearGradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    barRadius: Radius.circular(8.r),
                    animation: true,
                    animationDuration: 800,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
