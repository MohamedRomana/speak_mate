import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../core/widgets/voice_player.dart';
import '../../../../../../gen/fonts.gen.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../data/models/therapist_message.dart';

/// فقاعة رسالة محادثة الأخصائي (واتساب-ستايل) مع علامات الحالة والاقتباس.
class TMessageBubble extends StatelessWidget {
  final TMessage message;
  const TMessageBubble({super.key, required this.message});

  String _timeLabel() {
    final d = message.time;
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'ص' : 'م';
    return '$h:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final bg = isMe
        ? AppColors.primary.withValues(alpha: AppColors.isDark ? 0.9 : 1)
        : AppColors.card;
    final fg = isMe ? Colors.white : AppColors.mainText;

    return Align(
      alignment: isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(message.type == MsgType.image ? 5.w : 9.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(16.r),
            topEnd: Radius.circular(16.r),
            bottomStart: Radius.circular(isMe ? 16.r : 4.r),
            bottomEnd: Radius.circular(isMe ? 4.r : 16.r),
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.replyTo != null) _ReplyQuote(reply: message.replyTo!, onMe: isMe),
            _content(fg),
            SizedBox(height: 3.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppText(
                  text: _timeLabel(),
                  size: 9.sp,
                  color: isMe ? Colors.white.withValues(alpha: 0.85) : AppColors.secondaryText,
                ),
                if (isMe) ...[
                  SizedBox(width: 4.w),
                  _StatusTicks(status: message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(Color fg) {
    switch (message.type) {
      case MsgType.text:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: AppText(
            text: message.text,
            size: 14.sp,
            lines: 100,
            overflow: TextOverflow.visible,
            color: fg,
          ),
        );
      case MsgType.voice:
        return VoicePlayer(
          path: message.voicePath,
          durationMs: message.audioSeconds * 1000,
          foreground: fg,
          trackColor: fg.withValues(alpha: 0.35),
          width: 130,
        );
      case MsgType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(
            File(message.imagePath!),
            width: 0.6.sw,
            fit: BoxFit.cover,
          ),
        );
    }
  }
}

class _ReplyQuote extends StatelessWidget {
  final TReplyRef reply;
  final bool onMe;
  const _ReplyQuote({required this.reply, required this.onMe});

  @override
  Widget build(BuildContext context) {
    final accent = onMe ? Colors.white : AppColors.primary;
    final preview = switch (reply.type) {
      MsgType.voice => '🎤 ${LocaleKeys.voiceMessage.tr()}',
      MsgType.image => '📷 ${LocaleKeys.photo.tr()}',
      MsgType.text => reply.text,
    };
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 5.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: (onMe ? Colors.white : AppColors.primary).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: BorderDirectional(start: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: reply.sender == MsgSender.me
                ? LocaleKeys.you.tr()
                : LocaleKeys.chatWithTherapist.tr(),
            size: 10.sp,
            family: FontFamily.tajawalBold,
            color: accent,
          ),
          AppText(
            text: preview,
            size: 11.sp,
            color: onMe ? Colors.white.withValues(alpha: 0.85) : AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

class _StatusTicks extends StatelessWidget {
  final MsgStatus status;
  const _StatusTicks({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == MsgStatus.sending) {
      return Icon(Icons.access_time_rounded,
          size: 12.w, color: Colors.white.withValues(alpha: 0.8));
    }
    final read = status == MsgStatus.read;
    return Icon(
      status == MsgStatus.sent ? Icons.done_rounded : Icons.done_all_rounded,
      size: 14.w,
      color: read ? const Color(0xff8FD0FF) : Colors.white.withValues(alpha: 0.85),
    );
  }
}

/// فاصل تاريخ بين الرسائل (اليوم/أمس/تاريخ).
class DateSeparator extends StatelessWidget {
  final DateTime date;
  const DateSeparator({super.key, required this.date});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return LocaleKeys.today.tr();
    if (diff == 1) return LocaleKeys.yesterday.tr();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: AppText(
          text: _label(),
          size: 11.sp,
          color: AppColors.secondaryText,
          family: FontFamily.tajawalMedium,
        ),
      ),
    );
  }
}
