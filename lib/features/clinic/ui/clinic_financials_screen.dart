import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/colors.dart';
import '../../../core/di/dependancy_injection.dart';
import '../../../core/helper/extentions.dart';
import '../../../core/widgets/app_text.dart';
import '../../../gen/fonts.gen.dart';
import '../../../generated/locale_keys.g.dart';
import '../data/models/clinic_models.dart';
import '../data/repos/clinic_repo.dart';
import '../logic/clinic_finance_cubit.dart';

/// شاشة التقرير المالي للعيادة — إجماليات + إيرادات شهرية + إيراد كل أخصائي.
class ClinicFinancialsScreen extends StatelessWidget {
  const ClinicFinancialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClinicFinanceCubit(getIt<ClinicRepo>())..load(),
      child: const _FinancialsView(),
    );
  }
}

class _FinancialsView extends StatelessWidget {
  const _FinancialsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClinicFinanceCubit>();
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
          text: LocaleKeys.financialReport.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ClinicFinanceCubit, int>(
        builder: (context, _) {
          if (cubit.phase == FinancePhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cubit.phase == FinancePhase.error || cubit.data == null) {
            return Center(
              child: AppText(
                text: cubit.errorMsg ?? LocaleKeys.somethingWentWrong.tr(),
                size: 14.sp,
                color: AppColors.warning,
              ),
            );
          }
          final f = cubit.data!;
          return ListView(
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 28.h),
            children: [
              _TotalBanner(financials: f),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: LocaleKeys.paidAmount.tr(),
                      value: f.paidAmount,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _MiniStat(
                      label: LocaleKeys.pendingAmount.tr(),
                      value: f.pendingAmount,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _Card(
                title: LocaleKeys.revenueByMonth.tr(),
                child: _RevenueBars(
                  series: f.monthlyRevenue,
                  labels: f.monthLabels,
                ),
              ),
              SizedBox(height: 16.h),
              _Card(
                title: LocaleKeys.revenueByTherapist.tr(),
                child: Column(
                  children: [
                    for (final t in f.byTherapist)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _TherapistRevenue(
                          therapist: t,
                          maxRevenue: f.byTherapist
                              .map((e) => e.monthlyRevenue)
                              .fold(1, (a, b) => a > b ? a : b),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TotalBanner extends StatelessWidget {
  final ClinicFinancials financials;
  const _TotalBanner({required this.financials});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 26.w),
              SizedBox(width: 10.w),
              AppText(
                text: LocaleKeys.totalRevenue.tr(),
                size: 13.sp,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          AppText(
            text: '${financials.totalRevenue} ${LocaleKeys.currencySar.tr()}',
            size: 26.sp,
            family: FontFamily.tajawalBold,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(text: label, size: 12.sp, color: AppColors.secondaryText),
          SizedBox(height: 6.h),
          AppText(
            text: '$value ${LocaleKeys.currencySar.tr()}',
            size: 16.sp,
            family: FontFamily.tajawalBold,
            color: color,
            lines: 1,
          ),
        ],
      ),
    );
  }
}

/// أعمدة إيرادات شهرية بسيطة (ارتفاع متناسب مع أعلى قيمة) — بلا حزمة رسم.
class _RevenueBars extends StatelessWidget {
  final List<double> series;
  final List<String> labels;
  const _RevenueBars({required this.series, required this.labels});

  @override
  Widget build(BuildContext context) {
    final maxV = series.fold<double>(1, (a, b) => a > b ? a : b);
    return SizedBox(
      height: 150.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < series.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppText(
                    text: '${(series[i] / 1000).toStringAsFixed(1)}k',
                    size: 9.sp,
                    color: AppColors.secondaryText,
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    height: (110.h * (series[i] / maxV)).clamp(4.h, 110.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  AppText(
                    text: i < labels.length ? labels[i] : '',
                    size: 9.sp,
                    color: AppColors.secondaryText,
                    lines: 1,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TherapistRevenue extends StatelessWidget {
  final ClinicTherapist therapist;
  final int maxRevenue;
  const _TherapistRevenue({required this.therapist, required this.maxRevenue});

  @override
  Widget build(BuildContext context) {
    final ratio = maxRevenue == 0 ? 0.0 : therapist.monthlyRevenue / maxRevenue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText(
                text: therapist.name,
                size: 12.sp,
                family: FontFamily.tajawalMedium,
                color: AppColors.mainText,
                lines: 1,
              ),
            ),
            SizedBox(width: 8.w),
            AppText(
              text: '${therapist.monthlyRevenue} ${LocaleKeys.currencySar.tr()}',
              size: 12.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.primary,
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: LinearProgressIndicator(
            value: ratio.toDouble(),
            minHeight: 6.h,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

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
          AppText(
            text: title,
            size: 14.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.mainText,
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}
