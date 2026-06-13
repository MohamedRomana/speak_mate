import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/cache/cache_helper.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/di/dependancy_injection.dart';
import '../../../../../core/logic/action_state.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../core/widgets/custom_shimmer.dart';
import '../../../../../core/widgets/fade_slide_in.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../chat/logic/chat_cubit.dart';
import '../../chat/ui/chat_screen.dart';
import '../../chat_therapist/logic/therapist_chat_cubit.dart';
import '../../chat_therapist/ui/therapist_chat_screen.dart';
import '../../notifications/logic/notifications_cubit.dart';
import '../../notifications/ui/notifications_screen.dart';
import '../../session/logic/session_cubit.dart';
import '../../session/ui/session_screen.dart';
import '../logic/dashboard_cubit.dart';
import 'widgets/progress_chart.dart';
import 'widgets/session_card.dart';
import 'widgets/stat_card.dart';

/// تبويب الرئيسية للمتدرّب — لوحة الجلسات والتقدّم.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, ActionState>(
          builder: (context, state) {
            final cubit = context.read<DashboardCubit>();
            if (state is ActionLoading && cubit.data == null) {
              return const _DashboardShimmer();
            }
            final data = cubit.data;
            if (data == null) return const SizedBox.shrink();

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: cubit.load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _GreetingHeader(),
                    SizedBox(height: 20.h),
                    FadeSlideIn(
                      child: Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              icon: Icons.local_fire_department_rounded,
                              value: '${data.streakDays}',
                              label: LocaleKeys.statStreak.tr(),
                              color: AppColors.warning,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: StatCard(
                              icon: Icons.check_circle_rounded,
                              value: '${data.sessionsCompleted}',
                              label: LocaleKeys.statSessions.tr(),
                              color: AppColors.success,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: StatCard(
                              icon: Icons.track_changes_rounded,
                              value: '${data.accuracy}%',
                              label: LocaleKeys.statAccuracy.tr(),
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      child: _Card(
                        title: LocaleKeys.accuracyTrend.tr(),
                        icon: Icons.show_chart_rounded,
                        badge: LocaleKeys.thisWeek.tr(),
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: ProgressChart(series: data.accuracySeries),
                        ),
                      ),
                    ),
                    SizedBox(height: 22.h),
                    _SectionHeader(title: LocaleKeys.upcomingSessions.tr()),
                    SizedBox(height: 12.h),
                    if (data.upcoming.isEmpty)
                      _EmptyHint(text: LocaleKeys.noUpcomingSessions.tr())
                    else
                      ...data.upcoming.map(
                        (s) => SessionCard(
                          session: s,
                          onStart: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) => SessionCubit()..start(),
                                  child: SessionScreen(session: s),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 14.h),
                    _SectionHeader(title: LocaleKeys.pastSessions.tr()),
                    SizedBox(height: 12.h),
                    ...data.completed.map((s) => SessionCard(session: s)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    final name = CacheHelper.getUserName();
    final cubit = context.read<DashboardCubit>();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: '${LocaleKeys.hello.tr()}، $name 👋',
                size: 20.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
              ),
              SizedBox(height: 4.h),
              AppText(
                text: (cubit.data?.motivationKey ?? LocaleKeys.motivation1).tr(),
                size: 12.sp,
                lines: 2,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        const _TherapistChatButton(),
        SizedBox(width: 8.w),
        const _ChatButton(),
        SizedBox(width: 8.w),
        const _NotificationBell(),
      ],
    );
  }
}

class _TherapistChatButton extends StatelessWidget {
  const _TherapistChatButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => TherapistChatCubit(
                getIt(),
                lang: context.locale.languageCode,
              )..init(),
              child: const TherapistChatScreen(),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          Icons.chat_bubble_outline_rounded,
          color: AppColors.secondary,
          size: 22.w,
        ),
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) =>
                  ChatCubit(getIt(), lang: context.locale.languageCode)..init(),
              child: const ChatScreen(),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(
          Icons.smart_toy_rounded,
          color: Colors.white,
          size: 24.w,
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, ActionState>(
      builder: (context, _) {
        final unread = context.read<NotificationsCubit>().unreadCount;
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<NotificationsCubit>(),
                  child: const NotificationsScreen(),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.mainText,
                  size: 24.w,
                ),
                if (unread > 0)
                  PositionedDirectional(
                    top: 10.h,
                    end: 12.w,
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? badge;
  final Widget child;

  const _Card({
    required this.title,
    required this.icon,
    required this.child,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.w, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: AppText(
                  text: title,
                  size: 15.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.mainText,
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.softPrimary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: AppText(
                    text: badge!,
                    size: 10.sp,
                    color: AppColors.primary,
                    family: FontFamily.tajawalMedium,
                  ),
                ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: title,
      size: 16.sp,
      family: FontFamily.tajawalBold,
      color: AppColors.mainText,
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: AppText(
        text: text,
        size: 13.sp,
        textAlign: TextAlign.center,
        color: AppColors.secondaryText,
      ),
    );
  }
}

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    Widget box(double h, {double r = 18}) => CustomShimmer(
          child: Container(
            height: h,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(r),
            ),
          ),
        );
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          box(60.h),
          SizedBox(height: 20.h),
          box(90.h),
          SizedBox(height: 20.h),
          box(190.h),
          SizedBox(height: 20.h),
          box(110.h),
          SizedBox(height: 12.h),
          box(110.h),
        ],
      ),
    );
  }
}
