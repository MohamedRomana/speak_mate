import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/dependancy_injection.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../auth/data/models/user_role.dart';
import '../../../users/patient/settings/ui/settings_screen.dart';
import '../../support/ui/support_screen.dart';
import '../data/repos/account_repo.dart';
import '../logic/account_cubit.dart';

/// شاشة "حسابي" للأدوار غير الطفل (أخصائي/بالغ/عيادة): معلومات + إعدادات + دعم.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountCubit(getIt<AccountRepo>())..load(),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView();

  void _logout(BuildContext context) {
    CacheHelper.setUserId('');
    CacheHelper.setUserType('');
    context.pushNamedAndRemoveUntil(Routes.roleSelection, predicate: (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AccountCubit>();
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
          text: LocaleKeys.myAccount.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AccountCubit, int>(
        builder: (context, _) {
          if (cubit.phase == AccountPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cubit.phase == AccountPhase.error || cubit.user == null) {
            return Center(
              child: AppText(
                text: cubit.errorMsg ?? LocaleKeys.somethingWentWrong.tr(),
                size: 14.sp,
                color: AppColors.warning,
              ),
            );
          }
          final u = cubit.user!;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(user: u),
                SizedBox(height: 18.h),
                _InfoCard(user: u),
                SizedBox(height: 16.h),
                _Tile(
                  icon: Icons.settings_outlined,
                  label: LocaleKeys.settings.tr(),
                  onTap: () => context.pushScreen(const SettingsScreen()),
                ),
                _Tile(
                  icon: Icons.help_outline_rounded,
                  label: LocaleKeys.support.tr(),
                  onTap: () => context.pushScreen(const SupportScreen()),
                ),
                _Tile(
                  icon: Icons.logout_rounded,
                  label: LocaleKeys.logout.tr(),
                  danger: true,
                  onTap: () => _logout(context),
                  isLast: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppUser user;
  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    final initial = user.name.isNotEmpty ? user.name.characters.first : '?';
    return Column(
      children: [
        Container(
          width: 88.w,
          height: 88.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
          child: AppText(
            text: initial,
            size: 36.sp,
            family: FontFamily.tajawalBold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        AppText(
          text: user.name,
          size: 18.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppColors.softPrimary,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: AppText(
            text: user.role.titleKey.tr(),
            size: 12.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final AppUser user;
  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      if (user.email != null && user.email!.isNotEmpty)
        (Icons.email_outlined, LocaleKeys.email.tr(), user.email!),
      if (user.phone != null && user.phone!.isNotEmpty)
        (Icons.phone_outlined, LocaleKeys.phone.tr(), user.phone!),
      if (user.age != null)
        (Icons.cake_outlined, LocaleKeys.age.tr(), '${user.age}'),
      if (user.specialty != null && user.specialty!.isNotEmpty)
        (Icons.medical_services_outlined, LocaleKeys.specialty.tr(), user.specialty!),
      if (user.licenseNumber != null && user.licenseNumber!.isNotEmpty)
        (Icons.badge_outlined, LocaleKeys.licenseNumber.tr(), user.licenseNumber!),
      if (user.yearsOfExperience != null)
        (Icons.workspace_premium_outlined, LocaleKeys.yearsExperience.tr(),
            '${user.yearsOfExperience}'),
    ];
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Row(
              children: [
                Icon(rows[i].$1, size: 20.w, color: AppColors.primary),
                SizedBox(width: 12.w),
                Expanded(
                  child: AppText(
                    text: rows[i].$2,
                    size: 13.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
                Flexible(
                  child: AppText(
                    text: rows[i].$3,
                    size: 13.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            if (i < rows.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Divider(height: 1, color: AppColors.border),
              ),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool isLast;
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.mainText;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22.w, color: danger ? AppColors.error : AppColors.primary),
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
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14.w, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
