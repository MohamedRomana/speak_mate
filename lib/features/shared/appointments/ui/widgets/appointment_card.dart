import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../data/models/appointment.dart';

/// كرت موعد — يعرض الأخصائي (جانب المتدرّب) أو المريض (جانب الأخصائي عبر
/// [showPatient]) + تاريخ/وقت + نوع الجلسة + حالة. أزرار: إلغاء للمتدرّب،
/// قبول/رفض لطلبات الأخصائي المعلّقة.
class AppointmentCard extends StatelessWidget {
  final Appointment appt;
  final VoidCallback? onCancel;
  final bool showPatient;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCall; // بدء/الانضمام لمكالمة الجلسة
  const AppointmentCard({
    super.key,
    required this.appt,
    this.onCancel,
    this.showPatient = false,
    this.onAccept,
    this.onDecline,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = appt.type == AppointmentType.video;
    final (statusColor, statusKey) = switch (appt.status) {
      AppointmentStatus.pending => (AppColors.warning, LocaleKeys.pendingLabel),
      AppointmentStatus.scheduled => (AppColors.primary, LocaleKeys.statusScheduled),
      AppointmentStatus.completed => (AppColors.success, LocaleKeys.statusCompleted),
      AppointmentStatus.cancelled => (AppColors.error, LocaleKeys.statusCancelled),
    };
    return Container(
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (isVideo ? AppColors.secondary : AppColors.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isVideo ? Icons.videocam_rounded : Icons.local_hospital_rounded,
                  color: isVideo ? AppColors.secondary : AppColors.primary,
                  size: 22.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: showPatient ? appt.patientName : appt.therapistName,
                      size: 14.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.mainText,
                    ),
                    SizedBox(height: 3.h),
                    AppText(
                      text: appt.specialty,
                      size: 11.sp,
                      color: AppColors.secondaryText,
                      lines: 1,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: AppText(
                  text: statusKey.tr(),
                  size: 10.sp,
                  family: FontFamily.tajawalBold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 6.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_rounded,
                      size: 15.w, color: AppColors.secondaryText),
                  SizedBox(width: 6.w),
                  AppText(
                    text: _fmt(appt.dateTime),
                    size: 12.sp,
                    family: FontFamily.tajawalMedium,
                    color: AppColors.mainText,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 15.w, color: AppColors.secondaryText),
                  SizedBox(width: 6.w),
                  AppText(
                    text: '${appt.durationMinutes} ${LocaleKeys.minShort.tr()}',
                    size: 12.sp,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ],
          ),
          if (onCancel != null && appt.isUpcoming) ...[
            SizedBox(height: 10.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: Icon(Icons.close_rounded, size: 16.w, color: AppColors.error),
                label: AppText(
                  text: LocaleKeys.cancelAppointment.tr(),
                  size: 12.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
          if (onCall != null && appt.status == AppointmentStatus.scheduled) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isVideo ? AppColors.primary : AppColors.secondary,
                  padding: EdgeInsets.symmetric(vertical: 11.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: Icon(isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                    size: 18.w, color: Colors.white),
                label: AppText(
                  text: LocaleKeys.startSession.tr(),
                  size: 13.sp,
                  family: FontFamily.tajawalBold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          if (appt.isPending && (onAccept != null || onDecline != null)) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: AppText(
                      text: LocaleKeys.declineAction.tr(),
                      size: 12.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.error,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: AppText(
                      text: LocaleKeys.acceptAction.tr(),
                      size: 12.sp,
                      family: FontFamily.tajawalBold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}/${two(d.month)}/${two(d.day)} - ${two(d.hour)}:${two(d.minute)}';
  }
}
