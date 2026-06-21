import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/di/dependancy_injection.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/flash_message.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../data/models/appointment.dart';
import '../data/repos/appointments_repo.dart';
import '../logic/appointments_cubit.dart';

/// ورقة سفلية لحجز موعد. تأخذ [cubit] القائمة لإضافة الموعد الجديد عند النجاح.
Future<void> showBookAppointmentSheet(
  BuildContext context,
  AppointmentsCubit cubit,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.scaffoldBg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const _BookSheet(),
    ),
  );
}

class _BookSheet extends StatefulWidget {
  const _BookSheet();

  @override
  State<_BookSheet> createState() => _BookSheetState();
}

class _BookSheetState extends State<_BookSheet> {
  final _repo = getIt<AppointmentsRepo>();
  List<TherapistOption> _therapists = [];
  TherapistOption? _therapist;
  DateTime? _date;
  TimeOfDay? _time;
  AppointmentType _type = AppointmentType.video;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTherapists();
  }

  Future<void> _loadTherapists() async {
    final res = await _repo.getTherapists();
    if (!mounted) return;
    if (res is Success<List<TherapistOption>>) {
      setState(() {
        _therapists = res.data;
        _therapist = res.data.isNotEmpty ? res.data.first : null;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  bool get _ready => _therapist != null && _date != null && _time != null;

  DateTime get _dateTime => DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _time!.hour,
        _time!.minute,
      );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (t != null) setState(() => _time = t);
  }

  Future<void> _confirm() async {
    final cubit = context.read<AppointmentsCubit>();
    final ok = await cubit.book(
      therapist: _therapist!,
      dateTime: _dateTime,
      type: _type,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    showFlashMessage(
      message: ok
          ? LocaleKeys.appointmentBooked.tr()
          : (cubit.errorMsg ?? LocaleKeys.somethingWentWrong.tr()),
      type: ok ? FlashMessageType.success : FlashMessageType.error,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18.w,
        right: 18.w,
        top: 14.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            AppText(
              text: LocaleKeys.bookAppointment.tr(),
              size: 17.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.mainText,
            ),
            SizedBox(height: 16.h),
            if (_loading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const Center(child: CircularProgressIndicator()),
              )
            else ...[
              _label(LocaleKeys.chooseTherapist.tr()),
              SizedBox(height: 8.h),
              ..._therapists.map(_therapistTile),
              SizedBox(height: 14.h),
              _label(LocaleKeys.chooseDateTime.tr()),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _pickerBox(
                      icon: Icons.event_rounded,
                      text: _date == null
                          ? LocaleKeys.pickDate.tr()
                          : '${_date!.year}/${_date!.month}/${_date!.day}',
                      onTap: _pickDate,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _pickerBox(
                      icon: Icons.schedule_rounded,
                      text: _time == null
                          ? LocaleKeys.pickTime.tr()
                          : _time!.format(context),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _label(LocaleKeys.sessionType.tr()),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: _typeTile(AppointmentType.video, Icons.videocam_rounded,
                        LocaleKeys.videoSessionLabel.tr()),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _typeTile(AppointmentType.clinic,
                        Icons.local_hospital_rounded, LocaleKeys.inClinic.tr()),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              BlocBuilder<AppointmentsCubit, int>(
                builder: (context, _) => PrimaryButton(
                  text: LocaleKeys.confirmBooking.tr(),
                  icon: Icons.check_rounded,
                  enabled: _ready,
                  loading: context.read<AppointmentsCubit>().busy,
                  onPressed: _confirm,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => AppText(
        text: text,
        size: 13.sp,
        family: FontFamily.tajawalBold,
        color: AppColors.mainText,
      );

  Widget _therapistTile(TherapistOption t) {
    final selected = _therapist?.id == t.id;
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: () => setState(() => _therapist = t),
      child: Container(
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.card,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.secondaryText,
              size: 20.w,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: t.name,
                    size: 13.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                  ),
                  SizedBox(height: 2.h),
                  AppText(
                    text: t.specialty,
                    size: 11.sp,
                    color: AppColors.secondaryText,
                    lines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerBox({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.w, color: AppColors.primary),
            SizedBox(width: 8.w),
            Expanded(
              child: AppText(
                text: text,
                size: 12.sp,
                color: AppColors.mainText,
                lines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeTile(AppointmentType type, IconData icon, String text) {
    final selected = _type == type;
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.card,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 22.w,
                color: selected ? AppColors.primary : AppColors.secondaryText),
            SizedBox(height: 6.h),
            AppText(
              text: text,
              size: 12.sp,
              family: FontFamily.tajawalMedium,
              color: selected ? AppColors.primary : AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
