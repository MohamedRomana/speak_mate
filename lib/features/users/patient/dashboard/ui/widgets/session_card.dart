import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../gen/fonts.gen.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../data/models/session_model.dart';

/// بطاقة جلسة — قادمة (مع زر بدء + تذكير) أو مكتملة (مع نتيجة).
class SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback? onStart;

  const SessionCard({super.key, required this.session, this.onStart});

  bool get _isGroup => session.type == SessionType.group;
  bool get _isUpcoming => session.status == SessionStatus.upcoming;

  String _whenLabel() {
    final dt = session.dateTime;
    final now = DateTime.now();
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final tomorrow = now.add(const Duration(days: 1));
    final isTomorrow = dt.year == tomorrow.year &&
        dt.month == tomorrow.month &&
        dt.day == tomorrow.day;
    if (sameDay) return '${LocaleKeys.today.tr()} • $time';
    if (isTomorrow) return '${LocaleKeys.tomorrow.tr()} • $time';
    return '${dt.day}/${dt.month} • $time';
  }

  @override
  Widget build(BuildContext context) {
    final color = _isGroup ? AppColors.secondary : AppColors.primary;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
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
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  _isGroup ? Icons.groups_rounded : Icons.record_voice_over_rounded,
                  color: color,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: session.title,
                      size: 14.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.mainText,
                    ),
                    SizedBox(height: 3.h),
                    AppText(
                      text:
                          '${LocaleKeys.withWord.tr()} ${session.therapistName}',
                      size: 11.sp,
                      color: AppColors.secondaryText,
                    ),
                  ],
                ),
              ),
              if (!_isUpcoming && session.score != null)
                _ScoreBadge(score: session.score!),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _Chip(
                icon: Icons.access_time_rounded,
                label: _whenLabel(),
              ),
              SizedBox(width: 8.w),
              _Chip(
                icon: Icons.timelapse_rounded,
                label: '${session.durationMinutes} ${LocaleKeys.minShort.tr()}',
              ),
              const Spacer(),
              if (_isUpcoming && onStart != null)
                GestureDetector(
                  onTap: onStart,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: AppText(
                      text: LocaleKeys.startSession.tr(),
                      size: 12.sp,
                      family: FontFamily.tajawalBold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.w, color: AppColors.secondaryText),
          SizedBox(width: 4.w),
          AppText(
            text: label,
            size: 10.sp,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? AppColors.success
        : (score >= 60 ? AppColors.warning : AppColors.error);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          AppText(
            text: '$score%',
            size: 14.sp,
            family: FontFamily.tajawalBold,
            color: color,
          ),
          AppText(
            text: LocaleKeys.score.tr(),
            size: 9.sp,
            color: color,
          ),
        ],
      ),
    );
  }
}
