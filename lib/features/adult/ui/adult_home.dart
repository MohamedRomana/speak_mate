import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
import '../../shared/plans/ui/my_plan_cta.dart';
import '../../users/patient/chat/logic/chat_cubit.dart';
import '../../users/patient/chat/ui/chat_screen.dart';
import '../../users/patient/chat_therapist/logic/therapist_chat_cubit.dart';
import '../../users/patient/chat_therapist/ui/session_call.dart';
import '../../users/patient/chat_therapist/ui/therapist_chat_screen.dart';
import '../../users/patient/dashboard/ui/widgets/session_card.dart';
import '../data/models/rehab_models.dart';
import '../logic/adult_home_cubit.dart';
import '../logic/rehab_session_cubit.dart';
import 'rehab_session_screen.dart';

/// لوحة وحدة الكبار (إعادة التأهيل) — طابع سريري احترافي.
class AdultHomeScreen extends StatelessWidget {
  const AdultHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdultHomeCubit(getIt())..load(),
      child: const _AdultHomeView(),
    );
  }
}

class _AdultHomeView extends StatelessWidget {
  const _AdultHomeView();

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
        child: BlocBuilder<AdultHomeCubit, ActionState>(
          builder: (context, state) {
            final cubit = context.read<AdultHomeCubit>();
            if (state is ActionLoading && cubit.modules.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صف العنوان: الترحيب كامل (لا يُقتطع) + مبدّلات اللغة/الثيم فقط.
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text:
                              '${LocaleKeys.welcomeBack.tr()}، ${CacheHelper.getUserName()} 👋',
                          size: 18.sp,
                          family: FontFamily.tajawalBold,
                          color: AppColors.mainText,
                          lines: 1,
                        ),
                      ),
                      const LangToggle(),
                      SizedBox(width: 8.w),
                      const ThemeToggle(),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // صف الإجراءات: المساعد الذكي + محادثة الأخصائي + الحساب + الخروج.
                  Row(
                    children: [
                      _ActionTile(
                        icon: Icons.smart_toy_rounded,
                        gradient: true,
                        onTap: () => context.pushScreen(
                          BlocProvider(
                            create: (_) => ChatCubit(getIt(),
                                lang: context.locale.languageCode)
                              ..init(),
                            child: const ChatScreen(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      _ActionTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        color: AppColors.secondary,
                        onTap: () => context.pushScreen(
                          BlocProvider(
                            create: (_) => TherapistChatCubit(getIt(),
                                lang: context.locale.languageCode)
                              ..init(),
                            child: const TherapistChatScreen(),
                          ),
                        ),
                      ),
                      const Spacer(),
                      _ActionTile(
                        icon: Icons.person_outline_rounded,
                        onTap: () => context.pushScreen(const AccountScreen()),
                      ),
                      SizedBox(width: 10.w),
                      _ActionTile(
                        icon: Icons.logout_rounded,
                        color: AppColors.error,
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  FadeSlideIn(child: _RecoveryCard(cubit: cubit)),
                  SizedBox(height: 16.h),
                  const FadeSlideIn(
                    delay: Duration(milliseconds: 60),
                    child: MyPlanCta(),
                  ),
                  SizedBox(height: 12.h),
                  const FadeSlideIn(
                    delay: Duration(milliseconds: 90),
                    child: AppointmentsCta(),
                  ),
                  SizedBox(height: 12.h),
                  const FadeSlideIn(
                    delay: Duration(milliseconds: 120),
                    child: SubscriptionCta(),
                  ),
                  SizedBox(height: 20.h),
                  AppText(
                    text: LocaleKeys.rehabProgram.tr(),
                    size: 16.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                  ),
                  SizedBox(height: 12.h),
                  ...cubit.modules.asMap().entries.map(
                        (e) => FadeSlideIn(
                          delay: Duration(milliseconds: 80 * e.key),
                          from: SlideFrom.bottom,
                          child: _ModuleCard(module: e.value),
                        ),
                      ),
                  if (cubit.upcoming.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    AppText(
                      text: LocaleKeys.upcomingSessions.tr(),
                      size: 16.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.mainText,
                    ),
                    SizedBox(height: 12.h),
                    ...cubit.upcoming.map(
                      (s) => SessionCard(
                        session: s,
                        onStart: () => openCallForSession(context, s),
                      ),
                    ),
                  ],
                  if (cubit.completed.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    AppText(
                      text: LocaleKeys.pastSessions.tr(),
                      size: 16.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.mainText,
                    ),
                    SizedBox(height: 12.h),
                    ...cubit.completed.map((s) => SessionCard(session: s)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// زرّ إجراء مربّع في رأس لوحة البالغ (مساعد ذكي/محادثة/حساب/خروج).
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool gradient;
  const _ActionTile({
    required this.icon,
    required this.onTap,
    this.color,
    this.gradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 44.w,
        height: 44.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gradient ? null : AppColors.card,
          gradient: gradient
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary])
              : null,
          borderRadius: BorderRadius.circular(14.r),
          border: gradient ? null : Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 22.w,
          color: gradient ? Colors.white : (color ?? AppColors.primary),
        ),
      ),
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  final AdultHomeCubit cubit;
  const _RecoveryCard({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 40.r,
            lineWidth: 8.w,
            percent: (cubit.recoveryProgress / 100).clamp(0, 1),
            animation: true,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            progressColor: Colors.white,
            center: AppText(
              text: '${cubit.recoveryProgress}%',
              size: 16.sp,
              family: FontFamily.tajawalBold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: LocaleKeys.recoveryProgress.tr(),
                  size: 15.sp,
                  family: FontFamily.tajawalBold,
                  color: Colors.white,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _miniStat('${cubit.avgAccuracy}%',
                          LocaleKeys.avgAccuracyLabel.tr()),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _miniStat('${cubit.weeklySessions}',
                          LocaleKeys.weeklySessions.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: value,
          size: 18.sp,
          family: FontFamily.tajawalBold,
          color: Colors.white,
        ),
        AppText(
          text: label,
          size: 9.sp,
          lines: 2,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final RehabModule module;
  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () => context.pushScreen(
          BlocProvider(
            create: (_) =>
                RehabSessionCubit(getIt(), module: module)..start(),
            child: RehabSessionScreen(module: module),
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(module.icon, color: module.color, size: 26.w),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: module.titleKey.tr(),
                      size: 15.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.mainText,
                    ),
                    SizedBox(height: 3.h),
                    AppText(
                      text: module.descKey.tr(),
                      size: 11.sp,
                      lines: 2,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: LinearProgressIndicator(
                        value: module.progress / 100,
                        minHeight: 5.h,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(module.color),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Transform.flip(
                flipX: context.locale.languageCode == 'ar',
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 15.w, color: module.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
