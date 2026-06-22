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
import '../logic/therapist_schedule_cubit.dart';
import 'widgets/appointment_card.dart';

/// شاشة جدول مواعيد الأخصائي — طلبات قيد الانتظار (قبول/رفض) + مؤكَّدة + سابقة.
class TherapistScheduleScreen extends StatelessWidget {
  const TherapistScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TherapistScheduleCubit(getIt<AppointmentsRepo>())..load(),
      child: const _ScheduleView(),
    );
  }
}

class _ScheduleView extends StatelessWidget {
  const _ScheduleView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TherapistScheduleCubit>();
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
          text: LocaleKeys.schedule.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TherapistScheduleCubit, int>(
        builder: (context, _) {
          if (cubit.phase == SchedulePhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cubit.phase == SchedulePhase.error) {
            return Center(
              child: AppText(
                text: cubit.errorMsg ?? LocaleKeys.somethingWentWrong.tr(),
                size: 14.sp,
                color: AppColors.warning,
              ),
            );
          }
          final pending = cubit.pending;
          final upcoming = cubit.upcoming;
          final past = cubit.past;
          if (pending.isEmpty && upcoming.isEmpty && past.isEmpty) {
            return Center(
              child: AppText(
                text: LocaleKeys.noAppointments.tr(),
                size: 14.sp,
                color: AppColors.secondaryText,
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: cubit.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
              children: [
                if (pending.isNotEmpty) ...[
                  _header('${LocaleKeys.pendingRequests.tr()} (${pending.length})',
                      AppColors.warning),
                  SizedBox(height: 10.h),
                  ...pending.map((a) => AppointmentCard(
                        appt: a,
                        showPatient: true,
                        onAccept: () => _act(context, cubit.confirm(a.id),
                            LocaleKeys.requestAccepted.tr()),
                        onDecline: () => _act(context, cubit.decline(a.id),
                            LocaleKeys.requestDeclined.tr()),
                      )),
                  SizedBox(height: 8.h),
                ],
                if (upcoming.isNotEmpty) ...[
                  _header(LocaleKeys.confirmedAppointments.tr(), AppColors.primary),
                  SizedBox(height: 10.h),
                  ...upcoming.map((a) => AppointmentCard(
                        appt: a,
                        showPatient: true,
                        onCall: () => openSessionCall(
                          context,
                          therapistName: a.patientName,
                          isVideo: a.type == AppointmentType.video,
                        ),
                      )),
                  SizedBox(height: 8.h),
                ],
                if (past.isNotEmpty) ...[
                  _header(LocaleKeys.pastTab.tr(), AppColors.secondaryText),
                  SizedBox(height: 10.h),
                  ...past.map((a) => AppointmentCard(appt: a, showPatient: true)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(String text, Color color) => Row(
        children: [
          Container(width: 4.w, height: 16.h, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: AppText(
              text: text,
              size: 15.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.mainText,
            ),
          ),
        ],
      );

  Future<void> _act(
      BuildContext context, Future<bool> action, String successMsg) async {
    final ok = await action;
    if (!context.mounted) return;
    if (ok) {
      showFlashMessage(
        message: successMsg,
        type: FlashMessageType.success,
        context: context,
      );
    }
  }
}
