import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/helper/extentions.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../data/models/therapist_message.dart';
import '../logic/therapist_chat_cubit.dart';
import 'widgets/t_chat_input_bar.dart';
import 'widgets/t_message_bubble.dart';

/// شاشة محادثة الأخصائي (واتساب-ستايل).
class TherapistChatScreen extends StatefulWidget {
  const TherapistChatScreen({super.key});

  @override
  State<TherapistChatScreen> createState() => _TherapistChatScreenState();
}

class _TherapistChatScreenState extends State<TherapistChatScreen> {
  final _scroll = ScrollController();

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: _Header(),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<TherapistChatCubit, int>(
              listener: (context, _) => _toBottom(),
              builder: (context, _) {
                final cubit = context.read<TherapistChatCubit>();
                final items = _withSeparators(cubit.messages);
                return ListView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  itemCount: items.length + (cubit.typing ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == items.length) return const _TypingBubble();
                    final entry = items[i];
                    if (entry is DateTime) return DateSeparator(date: entry);
                    final msg = entry as TMessage;
                    return GestureDetector(
                      onLongPress: () => cubit.setReply(msg),
                      child: TMessageBubble(message: msg),
                    );
                  },
                );
              },
            ),
          ),
          const TChatInputBar(),
        ],
      ),
    );
  }

  /// يدمج فواصل التاريخ بين الرسائل.
  List<Object> _withSeparators(List<TMessage> msgs) {
    final out = <Object>[];
    DateTime? lastDay;
    for (final m in msgs) {
      final day = DateTime(m.time.year, m.time.month, m.time.day);
      if (lastDay == null || day != lastDay) {
        out.add(day);
        lastDay = day;
      }
      out.add(m);
    }
    return out;
  }
}

class _Header extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TherapistChatCubit>();
    return AppBar(
      backgroundColor: AppColors.card,
      elevation: 0.5,
      leadingWidth: 36.w,
      leading: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () => context.pop(),
        icon: Transform.flip(
          flipX: context.locale.languageCode == 'ar',
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18.w, color: AppColors.mainText),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary]),
            ),
            child: Icon(Icons.medical_services_rounded,
                color: Colors.white, size: 22.w),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: BlocBuilder<TherapistChatCubit, int>(
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cubit.therapistName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: FontFamily.tajawalBold,
                      color: AppColors.mainText,
                    ),
                  ),
                  Text(
                    cubit.typing
                        ? LocaleKeys.chatTyping.tr()
                        : LocaleKeys.chatStatus.tr(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: cubit.typing ? AppColors.primary : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.call_rounded, color: AppColors.primary, size: 22.w),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.videocam_rounded, color: AppColors.primary, size: 24.w),
        ),
      ],
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final t = (_c.value + i * 0.2) % 1.0;
              final scale = 0.6 + (0.4 * (1 - (t - 0.5).abs() * 2)).clamp(0.0, 1.0);
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryText,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
