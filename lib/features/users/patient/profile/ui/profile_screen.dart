import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/cache/cache_helper.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/di/dependancy_injection.dart';
import '../../../../../core/helper/extentions.dart';
import '../../../../../core/logic/action_state.dart';
import '../../../../../core/logic/refresh_emitter.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../core/widgets/custom_shimmer.dart';
import '../../../../../core/widgets/fade_slide_in.dart';
import '../../../../../core/widgets/flash_message.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../reports/logic/reports_cubit.dart';
import '../../reports/ui/reports_screen.dart';
import '../../settings/ui/settings_screen.dart';
import '../data/models/patient_profile.dart';
import '../logic/profile_cubit.dart';
import 'edit_profile_screen.dart';
import 'widgets/profile_header.dart';
import 'widgets/recordings_section.dart';
import 'widgets/section_card.dart';

/// تبويب الملف الشخصي للمتدرّب.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: BlocConsumer<ProfileCubit, ActionState>(
        listener: (context, state) {
          state.whenOrNull(
            success: (msg) {
              if (msg != null && !isRefreshMessage(msg)) {
                showFlashMessage(
                  message: msg.tr(),
                  type: FlashMessageType.success,
                  context: context,
                );
              }
            },
            error: (msg) => showFlashMessage(
              message: msg,
              type: FlashMessageType.error,
              context: context,
            ),
          );
        },
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          if (state is ActionLoading && cubit.profile == null) {
            return const _ProfileShimmer();
          }
          final profile = cubit.profile;
          if (profile == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(
                  profile: profile,
                  onEditAvatar: cubit.pickAvatar,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20.h),
                      FadeSlideIn(child: _InfoSection(profile: profile)),
                      if ((profile.notes ?? '').isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 100),
                          child: _NotesSection(notes: profile.notes!),
                        ),
                      ],
                      SizedBox(height: 16.h),
                      const FadeSlideIn(
                        delay: Duration(milliseconds: 150),
                        child: RecordingsSection(),
                      ),
                      SizedBox(height: 16.h),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 200),
                        child: _SettingsSection(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final PatientProfile profile;
  const _InfoSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: LocaleKeys.personalInfo.tr(),
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.email_outlined,
            label: LocaleKeys.email.tr(),
            value: profile.email ?? '—',
          ),
          if (profile.phone != null)
            _InfoRow(
              icon: Icons.phone_outlined,
              label: LocaleKeys.phone.tr(),
              value: profile.phone!,
            ),
          if (profile.age != null)
            _InfoRow(
              icon: Icons.cake_outlined,
              label: LocaleKeys.age.tr(),
              value: '${profile.age} ${LocaleKeys.yearsOld.tr()}',
            ),
          if (profile.gender != null)
            _InfoRow(
              icon: Icons.wc_outlined,
              label: LocaleKeys.gender.tr(),
              value: (profile.gender == 'female'
                      ? LocaleKeys.female
                      : LocaleKeys.male)
                  .tr(),
            ),
          if (profile.difficultyType != null)
            _InfoRow(
              icon: Icons.healing_outlined,
              label: LocaleKeys.difficultyType.tr(),
              value: profile.difficultyType!.tr(),
              isLast: true,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.softPrimary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.w, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: label,
                  size: 11.sp,
                  color: AppColors.secondaryText,
                ),
                SizedBox(height: 2.h),
                AppText(
                  text: value,
                  size: 14.sp,
                  family: FontFamily.tajawalMedium,
                  color: AppColors.mainText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  final String notes;
  const _NotesSection({required this.notes});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: LocaleKeys.notes.tr(),
      icon: Icons.sticky_note_2_outlined,
      child: AppText(
        text: notes,
        size: 13.sp,
        lines: 6,
        overflow: TextOverflow.visible,
        color: AppColors.secondaryText,
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    return SectionCard(
      title: LocaleKeys.accountSettings.tr(),
      icon: Icons.settings_outlined,
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.bar_chart_rounded,
            label: LocaleKeys.reportsTitle.tr(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => ReportsCubit(
                      getIt(),
                      lang: context.locale.languageCode,
                    )..load(),
                    child: const ReportsScreen(),
                  ),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.edit_outlined,
            label: LocaleKeys.editProfile.tr(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: const EditProfileScreen(),
                  ),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.settings_outlined,
            label: LocaleKeys.settings.tr(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.logout_rounded,
            label: LocaleKeys.logout.tr(),
            danger: true,
            onTap: () {
              CacheHelper.setUserId('');
              CacheHelper.setUserType('');
              context.pushNamedAndRemoveUntil(
                Routes.roleSelection,
                predicate: (_) => false,
              );
            },
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool isLast;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.mainText;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isLast ? 6.h : 10.h),
        child: Row(
          children: [
            Icon(icon, size: 20.w, color: danger ? AppColors.error : AppColors.secondaryText),
            SizedBox(width: 12.w),
            Expanded(
              child: AppText(
                text: label,
                size: 14.sp,
                family: FontFamily.tajawalMedium,
                color: color,
              ),
            ),
            Transform.flip(
              flipX: context.locale.languageCode == 'ar',
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.w,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    Widget box(double h, {double? w, double r = 16}) => CustomShimmer(
          child: Container(
            height: h,
            width: w,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(r),
            ),
          ),
        );
    return SingleChildScrollView(
      child: Column(
        children: [
          box(220.h, r: 0),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                box(140.h),
                SizedBox(height: 16.h),
                box(120.h),
                SizedBox(height: 16.h),
                box(180.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
