import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/cache/cache_helper.dart';
import '../../../core/constants/colors.dart';
import '../../../core/di/dependancy_injection.dart';
import '../../../core/helper/extentions.dart';
import '../../../core/logic/action_state.dart';
import '../../../core/routing/routes.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/lang_toggle.dart';
import '../../../core/widgets/theme_toggle.dart';
import '../../../gen/fonts.gen.dart';
import '../../../generated/locale_keys.g.dart';
import '../../shared/account/ui/account_screen.dart';
import '../data/models/clinic_models.dart';
import '../logic/clinic_home_cubit.dart';

/// لوحة تحكّم العيادة (Admin) — إحصائيات + مواعيد اليوم + الفوترة.
class ClinicHomeScreen extends StatelessWidget {
  const ClinicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClinicHomeCubit(getIt())..load(),
      child: const _ClinicHomeView(),
    );
  }
}

class _ClinicHomeView extends StatelessWidget {
  const _ClinicHomeView();

  void _logout(BuildContext context) {
    CacheHelper.setUserId('');
    CacheHelper.setUserType('');
    context.pushNamedAndRemoveUntil(Routes.roleSelection, predicate: (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: BlocBuilder<ClinicHomeCubit, ActionState>(
          builder: (context, state) {
            final cubit = context.read<ClinicHomeCubit>();
            if (state is ActionLoading && cubit.appointments.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: '${LocaleKeys.welcomeBack.tr()}، ${CacheHelper.getUserName()} 🏥',
                          size: 17.sp,
                          family: FontFamily.tajawalBold,
                          color: AppColors.mainText,
                          lines: 1,
                        ),
                      ),
                      const LangToggle(),
                      SizedBox(width: 6.w),
                      const ThemeToggle(),
                      SizedBox(width: 4.w),
                      IconButton(
                        onPressed: () =>
                            context.pushScreen(const AccountScreen()),
                        icon: Icon(Icons.person_outline_rounded,
                            color: AppColors.primary, size: 22.w),
                      ),
                      IconButton(
                        onPressed: () => _logout(context),
                        icon: Icon(Icons.logout_rounded,
                            color: AppColors.error, size: 22.w),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  FadeSlideIn(child: _StatsGrid(stats: cubit.stats)),
                  SizedBox(height: 20.h),
                  _SectionTitle(LocaleKeys.appointmentsToday.tr()),
                  SizedBox(height: 12.h),
                  if (cubit.appointments.isEmpty)
                    AppText(
                      text: LocaleKeys.noAppointmentsToday.tr(),
                      color: AppColors.secondaryText,
                    )
                  else
                    ...cubit.appointments.asMap().entries.map(
                          (e) => FadeSlideIn(
                            delay: Duration(milliseconds: 50 * e.key),
                            from: SlideFrom.bottom,
                            child: _AppointmentCard(appt: e.value),
                          ),
                        ),
                  SizedBox(height: 16.h),
                  _SectionTitle(LocaleKeys.recentInvoices.tr()),
                  SizedBox(height: 12.h),
                  ...cubit.invoices.map((inv) => _InvoiceRow(invoice: inv)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
      size: 16.sp,
      family: FontFamily.tajawalBold,
      color: AppColors.mainText,
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final ClinicStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 2.3,
      children: [
        _stat(Icons.people_alt_rounded, '${stats.patients}',
            LocaleKeys.totalPatients.tr(), AppColors.primary),
        _stat(Icons.medical_services_rounded, '${stats.therapists}',
            LocaleKeys.therapistsCount.tr(), AppColors.secondary),
        _stat(Icons.event_available_rounded, '${stats.todayAppointments}',
            LocaleKeys.appointmentsToday.tr(), AppColors.accent),
        _stat(
            Icons.payments_rounded,
            '${stats.monthlyRevenue} ${LocaleKeys.currencySar.tr()}',
            LocaleKeys.monthlyRevenue.tr(),
            AppColors.warning),
      ],
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color) {
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
                  size: 15.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.mainText,
                  lines: 1,
                ),
                AppText(
                  text: label,
                  size: 9.sp,
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

class _AppointmentCard extends StatelessWidget {
  final ClinicAppointment appt;
  const _AppointmentCard({required this.appt});

  ({Color color, String key}) get _status => switch (appt.status) {
        ApptStatus.scheduled => (color: AppColors.primary, key: LocaleKeys.statusScheduled),
        ApptStatus.completed => (color: AppColors.success, key: LocaleKeys.statusCompleted),
        ApptStatus.cancelled => (color: AppColors.error, key: LocaleKeys.statusCancelled),
      };

  @override
  Widget build(BuildContext context) {
    final s = _status;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: (appt.isVideo ? AppColors.secondary : AppColors.primary)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              appt.isVideo ? Icons.videocam_rounded : Icons.person_rounded,
              color: appt.isVideo ? AppColors.secondary : AppColors.primary,
              size: 24.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: appt.patientName,
                  size: 14.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.mainText,
                ),
                SizedBox(height: 3.h),
                AppText(
                  text:
                      '${LocaleKeys.withTherapistLabel.tr()} ${appt.therapistName} • ${appt.isVideo ? LocaleKeys.videoSessionLabel.tr() : LocaleKeys.inClinic.tr()}',
                  size: 10.sp,
                  lines: 1,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                text: appt.timeLabel,
                size: 12.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: AppText(
                  text: s.key.tr(),
                  size: 9.sp,
                  color: s.color,
                  family: FontFamily.tajawalMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final Invoice invoice;
  const _InvoiceRow({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final paid = invoice.status == InvoiceStatus.paid;
    final color = paid ? AppColors.success : AppColors.warning;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 22.w, color: AppColors.secondaryText),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: invoice.patientName,
                  size: 13.sp,
                  family: FontFamily.tajawalMedium,
                  color: AppColors.mainText,
                ),
                AppText(
                  text: invoice.dateLabel,
                  size: 10.sp,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          AppText(
            text: '${invoice.amount} ${LocaleKeys.currencySar.tr()}',
            size: 14.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.mainText,
          ),
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: AppText(
              text: (paid ? LocaleKeys.paidLabel : LocaleKeys.pendingLabel).tr(),
              size: 9.sp,
              color: color,
              family: FontFamily.tajawalMedium,
            ),
          ),
        ],
      ),
    );
  }
}
