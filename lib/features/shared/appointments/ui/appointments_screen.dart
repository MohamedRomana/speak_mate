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
import '../../../users/patient/chat_therapist/ui/session_call.dart';
import '../data/models/appointment.dart';
import '../data/repos/appointments_repo.dart';
import '../logic/appointments_cubit.dart';
import 'book_appointment_sheet.dart';
import 'widgets/appointment_card.dart';

/// شاشة "مواعيدي" — قائمة المواعيد القادمة والسابقة + زر حجز.
class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppointmentsCubit(getIt<AppointmentsRepo>())..load(),
      child: const _AppointmentsView(),
    );
  }
}

class _AppointmentsView extends StatelessWidget {
  const _AppointmentsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppointmentsCubit>();
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
          text: LocaleKeys.myAppointments.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => showBookAppointmentSheet(context, cubit),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: AppText(
          text: LocaleKeys.bookAppointment.tr(),
          size: 13.sp,
          family: FontFamily.tajawalBold,
          color: Colors.white,
        ),
      ),
      body: BlocBuilder<AppointmentsCubit, int>(
        builder: (context, _) {
          if (cubit.phase == ApptPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cubit.phase == ApptPhase.error) {
            return Center(
              child: AppText(
                text: cubit.errorMsg ?? LocaleKeys.somethingWentWrong.tr(),
                size: 14.sp,
                color: AppColors.warning,
              ),
            );
          }
          final up = cubit.upcoming;
          final past = cubit.past;
          if (up.isEmpty && past.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy_rounded,
                      size: 56.w, color: AppColors.secondaryText),
                  SizedBox(height: 12.h),
                  AppText(
                    text: LocaleKeys.noAppointments.tr(),
                    size: 14.sp,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: cubit.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 90.h),
              children: [
                if (up.isNotEmpty) ...[
                  _header(LocaleKeys.upcomingTab.tr()),
                  SizedBox(height: 10.h),
                  ...up.map((a) => AppointmentCard(
                        appt: a,
                        onCancel: () => _confirmCancel(context, cubit, a.id),
                        onCall: () => openSessionCall(
                          context,
                          therapistName: a.therapistName,
                          isVideo: a.type == AppointmentType.video,
                        ),
                      )),
                ],
                if (past.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  _header(LocaleKeys.pastTab.tr()),
                  SizedBox(height: 10.h),
                  ...past.map((a) => AppointmentCard(appt: a)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(String text) => AppText(
        text: text,
        size: 15.sp,
        family: FontFamily.tajawalBold,
        color: AppColors.mainText,
      );

  Future<void> _confirmCancel(
    BuildContext context,
    AppointmentsCubit cubit,
    String id,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: AppText(
          text: LocaleKeys.cancelAppointment.tr(),
          size: 15.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: AppText(text: LocaleKeys.cancel.tr(), color: AppColors.secondaryText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: AppText(
              text: LocaleKeys.confirm.tr(),
              color: AppColors.error,
              family: FontFamily.tajawalBold,
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final done = await cubit.cancel(id);
    if (!context.mounted) return;
    if (done) {
      showFlashMessage(
        message: LocaleKeys.appointmentCancelled.tr(),
        type: FlashMessageType.success,
        context: context,
      );
    }
  }
}
