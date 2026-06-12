import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/helper/extentions.dart';
import '../../../../../core/logic/action_state.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../core/widgets/empty_data_widget.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../data/models/notification_item.dart';
import '../logic/notifications_cubit.dart';

/// شاشة الإشعارات — تذكيرات، تمارين، رسائل تحفيزية، وإنجازات.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Transform.flip(
            flipX: context.locale.languageCode == 'ar',
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.w,
              color: AppColors.mainText,
            ),
          ),
        ),
        title: AppText(
          text: LocaleKeys.notifications.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationsCubit>().markAllRead(),
            child: AppText(
              text: LocaleKeys.markAllRead.tr(),
              size: 12.sp,
              color: AppColors.primary,
              family: FontFamily.tajawalMedium,
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, ActionState>(
        builder: (context, state) {
          final items = context.read<NotificationsCubit>().items;
          if (items.isEmpty) {
            return EmptyDataWidget(message: LocaleKeys.noNotifications.tr());
          }
          return AnimationLimiter(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              itemCount: items.length,
              itemBuilder: (context, i) => AnimationConfiguration.staggeredList(
                position: i,
                duration: const Duration(milliseconds: 350),
                child: SlideAnimation(
                  verticalOffset: 40,
                  child: FadeInAnimation(
                    child: _NotificationTile(item: items[i]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  const _NotificationTile({required this.item});

  ({IconData icon, Color color, String label}) get _meta => switch (item.type) {
        NotificationType.reminder => (
            icon: Icons.alarm_rounded,
            color: AppColors.primary,
            label: LocaleKeys.notifReminder,
          ),
        NotificationType.exercise => (
            icon: Icons.sports_esports_rounded,
            color: AppColors.secondary,
            label: LocaleKeys.notifExercise,
          ),
        NotificationType.motivation => (
            icon: Icons.favorite_rounded,
            color: AppColors.error,
            label: LocaleKeys.notifMotivation,
          ),
        NotificationType.achievement => (
            icon: Icons.emoji_events_rounded,
            color: AppColors.warning,
            label: LocaleKeys.notifAchievement,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final meta = _meta;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: item.read ? AppColors.card : AppColors.softPrimary,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: item.read ? AppColors.border : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(meta.icon, color: meta.color, size: 22.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: item.title,
                        size: 14.sp,
                        family: FontFamily.tajawalBold,
                        color: AppColors.mainText,
                      ),
                    ),
                    AppText(
                      text: item.timeLabel,
                      size: 10.sp,
                      color: AppColors.secondaryText,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                AppText(
                  text: item.body,
                  size: 12.sp,
                  lines: 3,
                  overflow: TextOverflow.visible,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
