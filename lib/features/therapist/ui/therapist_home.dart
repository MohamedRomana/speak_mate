import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/cache/cache_helper.dart';
import '../../../core/constants/colors.dart';
import '../../../core/di/dependancy_injection.dart';
import '../../../core/helper/extentions.dart';
import '../../../core/routing/routes.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/lang_toggle.dart';
import '../../../core/widgets/theme_toggle.dart';
import '../../../gen/fonts.gen.dart';
import '../../../generated/locale_keys.g.dart';
import '../../shared/account/ui/account_screen.dart';
import '../../shared/appointments/ui/therapist_schedule_screen.dart';
import '../data/models/therapist_patient.dart';
import '../logic/therapist_home_cubit.dart';
import 'patient_detail_screen.dart';

/// لوحة الأخصائي — مرضى + بحث + فلترة + تحليلات.
class TherapistHomeScreen extends StatelessWidget {
  const TherapistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TherapistHomeCubit(getIt())..load(),
      child: const _TherapistHomeView(),
    );
  }
}

class _TherapistHomeView extends StatelessWidget {
  const _TherapistHomeView();

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
        child: BlocBuilder<TherapistHomeCubit, int>(
          builder: (context, _) {
            final cubit = context.read<TherapistHomeCubit>();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 4.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppText(
                            text: '${LocaleKeys.welcomeBack.tr()}، ${CacheHelper.getUserName()} 👋',
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
                              context.pushScreen(const TherapistScheduleScreen()),
                          icon: Icon(Icons.calendar_month_rounded,
                              color: AppColors.primary, size: 22.w),
                        ),
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
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: FadeSlideIn(child: _Analytics(cubit: cubit)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 10.h),
                    child: AppText(
                      text: LocaleKeys.myPatients.tr(),
                      size: 16.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.mainText,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _SearchBar(cubit: cubit)),
                SliverToBoxAdapter(child: _Filters(cubit: cubit)),
                if (cubit.loading && cubit.patients.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (cubit.patients.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: Center(
                        child: AppText(
                          text: LocaleKeys.noPatients.tr(),
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 24.h),
                    sliver: SliverList.builder(
                      itemCount: cubit.patients.length,
                      itemBuilder: (context, i) =>
                          _PatientCard(patient: cubit.patients[i]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Analytics extends StatelessWidget {
  final TherapistHomeCubit cubit;
  const _Analytics({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stat(Icons.people_alt_rounded, '${cubit.totalPatients}',
            LocaleKeys.totalPatients.tr(), AppColors.primary),
        SizedBox(width: 12.w),
        _stat(Icons.bolt_rounded, '${cubit.activeThisWeek}',
            LocaleKeys.activeThisWeek.tr(), AppColors.accent),
        SizedBox(width: 12.w),
        _stat(Icons.trending_up_rounded, '${cubit.avgProgress}%',
            LocaleKeys.avgProgressLabel.tr(), AppColors.secondary),
      ],
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.w),
            SizedBox(height: 6.h),
            AppText(
              text: value,
              size: 17.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.mainText,
            ),
            AppText(
              text: label,
              size: 9.sp,
              lines: 2,
              textAlign: TextAlign.center,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TherapistHomeCubit cubit;
  const _SearchBar({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          onChanged: cubit.setQuery,
          style: TextStyle(fontSize: 14.sp, color: AppColors.mainText),
          decoration: InputDecoration(
            hintText: LocaleKeys.searchPatient.tr(),
            hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.secondaryText),
            prefixIcon: Icon(Icons.search_rounded,
                color: AppColors.secondaryText, size: 20.w),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final TherapistHomeCubit cubit;
  const _Filters({required this.cubit});

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, PatientFilter f) {
      final sel = cubit.filter == f;
      return Padding(
        padding: EdgeInsetsDirectional.only(end: 8.w),
        child: GestureDetector(
          onTap: () => cubit.setFilter(f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: sel ? AppColors.primary : AppColors.border),
            ),
            child: AppText(
              text: label,
              size: 12.sp,
              family: FontFamily.tajawalMedium,
              color: sel ? Colors.white : AppColors.mainText,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 6.h),
      child: Row(
        children: [
          chip(LocaleKeys.filterAll.tr(), PatientFilter.all),
          chip(LocaleKeys.filterChild.tr(), PatientFilter.child),
          chip(LocaleKeys.filterAdult.tr(), PatientFilter.adult),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final TherapistPatient patient;
  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final color = patient.isChild ? AppColors.primary : AppColors.secondary;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () =>
            context.pushScreen(PatientDetailScreen(patient: patient)),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: color.withValues(alpha: 0.16),
                child: AppText(
                  text: patient.name.isNotEmpty ? patient.name[0] : '?',
                  size: 18.sp,
                  family: FontFamily.tajawalBold,
                  color: color,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: patient.name,
                      size: 14.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.mainText,
                    ),
                    SizedBox(height: 3.h),
                    AppText(
                      text:
                          '${(patient.isChild ? LocaleKeys.condChild : LocaleKeys.condAdult).tr()} • ${patient.age} • ${LocaleKeys.lastActiveLabel.tr()}: ${patient.lastActive}',
                      size: 10.sp,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: LinearProgressIndicator(
                        value: patient.progress / 100,
                        minHeight: 5.h,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                children: [
                  AppText(
                    text: '${patient.accuracy}%',
                    size: 15.sp,
                    family: FontFamily.tajawalBold,
                    color: color,
                  ),
                  AppText(
                    text: LocaleKeys.statAccuracy.tr(),
                    size: 8.sp,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
