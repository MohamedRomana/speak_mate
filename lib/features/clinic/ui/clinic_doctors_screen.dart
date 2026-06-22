import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/colors.dart';
import '../../../core/di/dependancy_injection.dart';
import '../../../core/helper/extentions.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/flash_message.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/satha_field.dart';
import '../../../gen/fonts.gen.dart';
import '../../../generated/locale_keys.g.dart';
import '../data/models/clinic_models.dart';
import '../data/repos/clinic_repo.dart';
import '../logic/clinic_staff_cubit.dart';

/// شاشة إدارة طاقم أطباء العيادة — عرض/إضافة/حذف.
class ClinicDoctorsScreen extends StatelessWidget {
  const ClinicDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClinicStaffCubit(getIt<ClinicRepo>())..load(),
      child: const _DoctorsView(),
    );
  }
}

class _DoctorsView extends StatelessWidget {
  const _DoctorsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClinicStaffCubit>();
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
          text: LocaleKeys.manageDoctors.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _add(context, cubit),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: AppText(
          text: LocaleKeys.addDoctor.tr(),
          size: 13.sp,
          family: FontFamily.tajawalBold,
          color: Colors.white,
        ),
      ),
      body: BlocBuilder<ClinicStaffCubit, int>(
        builder: (context, _) {
          if (cubit.phase == StaffPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cubit.phase == StaffPhase.error) {
            return Center(
              child: AppText(
                text: cubit.errorMsg ?? LocaleKeys.somethingWentWrong.tr(),
                size: 14.sp,
                color: AppColors.warning,
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 90.h),
            children: cubit.therapists
                .map((t) => _DoctorCard(
                      doctor: t,
                      onRemove: () => _remove(context, cubit, t),
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  Future<void> _add(BuildContext context, ClinicStaffCubit cubit) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => BlocProvider.value(value: cubit, child: const _AddDoctorSheet()),
    );
    if (ok == true && context.mounted) {
      showFlashMessage(
        message: LocaleKeys.doctorAdded.tr(),
        type: FlashMessageType.success,
        context: context,
      );
    }
  }

  Future<void> _remove(
      BuildContext context, ClinicStaffCubit cubit, ClinicTherapist t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: AppText(
          text: LocaleKeys.removeDoctor.tr(),
          size: 15.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        content: AppText(
          text: t.name,
          size: 13.sp,
          color: AppColors.secondaryText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: AppText(text: LocaleKeys.cancel.tr(), color: AppColors.secondaryText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: AppText(
              text: LocaleKeys.delete.tr(),
              color: AppColors.error,
              family: FontFamily.tajawalBold,
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final done = await cubit.removeTherapist(t.id);
    if (!context.mounted) return;
    if (done) {
      showFlashMessage(
        message: LocaleKeys.doctorRemoved.tr(),
        type: FlashMessageType.success,
        context: context,
      );
    }
  }
}

class _DoctorCard extends StatelessWidget {
  final ClinicTherapist doctor;
  final VoidCallback onRemove;
  const _DoctorCard({required this.doctor, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final initial = doctor.name.replaceFirst('د. ', '');
    return Container(
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.softPrimary,
                  shape: BoxShape.circle,
                ),
                child: AppText(
                  text: initial.isNotEmpty ? initial.characters.first : '?',
                  size: 20.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AppText(
                            text: doctor.name,
                            size: 14.sp,
                            family: FontFamily.tajawalBold,
                            color: AppColors.mainText,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (!doctor.active)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryText.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: AppText(
                              text: LocaleKeys.inactiveLabel.tr(),
                              size: 10.sp,
                              family: FontFamily.tajawalBold,
                              color: AppColors.secondaryText,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    AppText(
                      text: doctor.specialty,
                      size: 11.sp,
                      color: AppColors.secondaryText,
                      lines: 1,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.delete_outline_rounded,
                    size: 22.w, color: AppColors.error),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _stat(Icons.people_alt_rounded, '${doctor.patientsCount}',
                    LocaleKeys.patientsCountLabel.tr()),
              ),
              Expanded(
                child: _stat(Icons.payments_rounded,
                    '${doctor.monthlyRevenue} ${LocaleKeys.currencySar.tr()}',
                    LocaleKeys.totalRevenue.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: AppColors.primary),
        SizedBox(width: 6.w),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: value,
                size: 12.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
                lines: 1,
              ),
              AppText(
                text: label,
                size: 9.sp,
                color: AppColors.secondaryText,
                lines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddDoctorSheet extends StatefulWidget {
  const _AddDoctorSheet();

  @override
  State<_AddDoctorSheet> createState() => _AddDoctorSheetState();
}

class _AddDoctorSheetState extends State<_AddDoctorSheet> {
  final _name = TextEditingController();
  final _specialty = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _specialty.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty && _specialty.text.trim().isNotEmpty;

  Future<void> _save() async {
    final cubit = context.read<ClinicStaffCubit>();
    final ok = await cubit.addTherapist(
      name: _name.text.trim(),
      specialty: _specialty.text.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pop(ok);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ClinicStaffCubit>();
    return Padding(
      padding: EdgeInsets.only(
        left: 18.w,
        right: 18.w,
        top: 14.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18.h,
      ),
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
            text: LocaleKeys.addDoctor.tr(),
            size: 16.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.mainText,
          ),
          SizedBox(height: 16.h),
          SathaField(
            controller: _name,
            hint: LocaleKeys.doctorName.tr(),
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 12.h),
          SathaField(
            controller: _specialty,
            hint: LocaleKeys.specialty.tr(),
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 20.h),
          PrimaryButton(
            text: LocaleKeys.addDoctor.tr(),
            icon: Icons.check_rounded,
            enabled: _valid,
            loading: cubit.busy,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
