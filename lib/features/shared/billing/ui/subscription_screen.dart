import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/di/dependancy_injection.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/flash_message.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../data/models/billing_models.dart';
import '../data/repos/billing_repo.dart';
import '../logic/billing_cubit.dart';

/// شاشة الاشتراك — الباقة الحالية + الباقات المتاحة + سجل الفواتير.
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BillingCubit(getIt<BillingRepo>())..load(),
      child: const _SubscriptionView(),
    );
  }
}

class _SubscriptionView extends StatelessWidget {
  const _SubscriptionView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BillingCubit>();
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
          text: LocaleKeys.subscriptionTitle.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<BillingCubit, int>(
        builder: (context, _) {
          if (cubit.phase == BillingPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cubit.phase == BillingPhase.error) {
            return Center(
              child: AppText(
                text: cubit.errorMsg ?? LocaleKeys.somethingWentWrong.tr(),
                size: 14.sp,
                color: AppColors.warning,
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 28.h),
            children: [
              if (cubit.current != null) _CurrentBanner(sub: cubit.current!),
              SizedBox(height: 18.h),
              AppText(
                text: LocaleKeys.choosePlan.tr(),
                size: 15.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
              ),
              SizedBox(height: 12.h),
              ...cubit.plans.map((p) => _PlanCard(
                    plan: p,
                    isCurrent: cubit.isCurrent(p.id),
                    busy: cubit.subscribing,
                    onSubscribe: () => _subscribe(context, cubit, p),
                  )),
              if (cubit.invoices.isNotEmpty) ...[
                SizedBox(height: 22.h),
                AppText(
                  text: LocaleKeys.billingHistory.tr(),
                  size: 15.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.mainText,
                ),
                SizedBox(height: 12.h),
                ...cubit.invoices.map((i) => _InvoiceRow(invoice: i)),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _subscribe(
    BuildContext context,
    BillingCubit cubit,
    SubscriptionPlan plan,
  ) async {
    final ok = await cubit.subscribe(plan.id);
    if (!context.mounted) return;
    showFlashMessage(
      message: ok
          ? LocaleKeys.subscribedMsg.tr()
          : (cubit.errorMsg ?? LocaleKeys.somethingWentWrong.tr()),
      type: ok ? FlashMessageType.success : FlashMessageType.error,
      context: context,
    );
  }
}

class _CurrentBanner extends StatelessWidget {
  final Subscription sub;
  const _CurrentBanner({required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 30.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: LocaleKeys.currentPlan.tr(),
                  size: 12.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                SizedBox(height: 3.h),
                AppText(
                  text: sub.planName,
                  size: 17.sp,
                  family: FontFamily.tajawalBold,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isCurrent;
  final bool busy;
  final VoidCallback onSubscribe;
  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.busy,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = plan.isPopular;
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: highlight ? AppColors.primary : AppColors.border,
          width: highlight ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: plan.name,
                  size: 16.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.mainText,
                ),
              ),
              if (highlight)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: AppText(
                    text: LocaleKeys.popularBadge.tr(),
                    size: 10.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                text: plan.priceMonthly == 0
                    ? LocaleKeys.freePrice.tr()
                    : '${plan.priceMonthly} ${LocaleKeys.currencySar.tr()}',
                size: 22.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.primary,
              ),
              if (plan.priceMonthly != 0) ...[
                SizedBox(width: 4.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: AppText(
                    text: LocaleKeys.perMonth.tr(),
                    size: 12.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          ...plan.features.map((f) => Padding(
                padding: EdgeInsets.only(bottom: 7.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 16.w, color: AppColors.success),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: AppText(
                        text: f,
                        size: 12.sp,
                        lines: 2,
                        overflow: TextOverflow.visible,
                        color: AppColors.mainText,
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: isCurrent
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: AppText(
                      text: LocaleKeys.currentPlan.tr(),
                      size: 13.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.secondaryText,
                    ),
                  )
                : ElevatedButton(
                    onPressed: busy ? null : onSubscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: AppText(
                      text: LocaleKeys.subscribeAction.tr(),
                      size: 13.sp,
                      family: FontFamily.tajawalBold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final BillingInvoice invoice;
  const _InvoiceRow({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final (color, key) = switch (invoice.status) {
      PaymentStatus.paid => (AppColors.success, LocaleKeys.paidLabel),
      PaymentStatus.pending => (AppColors.warning, LocaleKeys.pendingLabel),
      PaymentStatus.failed => (AppColors.error, LocaleKeys.statusFailed),
    };
    return Container(
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long_rounded, size: 22.w, color: AppColors.secondaryText),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: invoice.planName,
                  size: 13.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.mainText,
                ),
                SizedBox(height: 3.h),
                AppText(
                  text: invoice.dateLabel,
                  size: 11.sp,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                text: '${invoice.amount} ${LocaleKeys.currencySar.tr()}',
                size: 13.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
              ),
              SizedBox(height: 3.h),
              AppText(
                text: key.tr(),
                size: 11.sp,
                family: FontFamily.tajawalBold,
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
