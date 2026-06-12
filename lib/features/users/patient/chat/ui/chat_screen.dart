import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/helper/extentions.dart';
import '../../../../../core/logic/action_state.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../logic/chat_cubit.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/typing_indicator.dart';

/// شاشة المحادثة مع المساعد الذكي.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scroll = ScrollController();

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
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
      appBar: _ChatAppBar(),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ActionState>(
              listener: (context, state) => _toBottom(),
              builder: (context, state) {
                final cubit = context.read<ChatCubit>();
                final msgs = cubit.messages;
                return ListView.builder(
                  controller: _scroll,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: msgs.length + (cubit.isTyping ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == msgs.length) return const TypingIndicator();
                    return ChatBubble(message: msgs[i]);
                  },
                );
              },
            ),
          ),
          const _Suggestions(),
          const ChatInputBar(),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.card,
      elevation: 0.5,
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
      title: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22.w),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                text: LocaleKeys.chatTitle.tr(),
                size: 15.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
              ),
              Row(
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  AppText(
                    text: LocaleKeys.chatStatus.tr(),
                    size: 11.sp,
                    color: AppColors.success,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ActionState>(
      builder: (context, _) {
        final cubit = context.read<ChatCubit>();
        if (cubit.suggestions.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 40.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            itemCount: cubit.suggestions.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, i) {
              final s = cubit.suggestions[i];
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  cubit.send(s);
                },
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.softPrimary,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: AppText(
                    text: s,
                    size: 12.sp,
                    color: AppColors.primary,
                    family: FontFamily.tajawalMedium,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
