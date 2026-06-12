import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../gen/fonts.gen.dart';
import '../../data/models/chat_message.dart';

/// فقاعة رسالة محادثة (نص أو صوت)، تتكيّف لون/محاذاة حسب المرسل.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _BotAvatar(),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: 0.72.sw),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      )
                    : null,
                color: isUser ? null : AppColors.card,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(18.r),
                  topEnd: Radius.circular(18.r),
                  bottomStart: Radius.circular(isUser ? 18.r : 4.r),
                  bottomEnd: Radius.circular(isUser ? 4.r : 18.r),
                ),
                border: isUser ? null : Border.all(color: AppColors.border),
              ),
              child: message.type == ChatMessageType.audio
                  ? _AudioContent(message: message, isUser: isUser)
                  : _TextContent(message: message, isUser: isUser),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextContent extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  const _TextContent({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final fg = isUser ? Colors.white : AppColors.mainText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: message.text,
          size: 14.sp,
          lines: 50,
          overflow: TextOverflow.visible,
          color: fg,
        ),
        SizedBox(height: 3.h),
        AppText(
          text: message.timeLabel,
          size: 9.sp,
          color: isUser
              ? Colors.white.withValues(alpha: 0.8)
              : AppColors.secondaryText,
        ),
      ],
    );
  }
}

class _AudioContent extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  const _AudioContent({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final fg = isUser ? Colors.white : AppColors.primary;
    final m = (message.audioSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (message.audioSeconds % 60).toString().padLeft(2, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.play_arrow_rounded, color: fg, size: 26.w),
        SizedBox(width: 6.w),
        Row(
          children: List.generate(14, (i) {
            final h = (i % 3 == 0 ? 16 : (i % 2 == 0 ? 10 : 6)).toDouble();
            return Container(
              width: 2.5.w,
              height: h.h,
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              decoration: BoxDecoration(
                color: fg.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(2.r),
              ),
            );
          }),
        ),
        SizedBox(width: 8.w),
        AppText(
          text: '$m:$s',
          size: 11.sp,
          family: FontFamily.tajawalMedium,
          color: fg,
        ),
      ],
    );
  }
}

class _BotAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16.w),
    );
  }
}
