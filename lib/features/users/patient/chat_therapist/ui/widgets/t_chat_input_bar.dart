import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/widgets/app_text.dart';
import '../../../../../../gen/fonts.gen.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../data/models/therapist_message.dart';
import '../../logic/therapist_chat_cubit.dart';

/// شريط إدخال محادثة الأخصائي (نص + إرفاق صورة + إرسال/صوت) + معاينة رد.
class TChatInputBar extends StatefulWidget {
  const TChatInputBar({super.key});

  @override
  State<TChatInputBar> createState() => _TChatInputBarState();
}

class _TChatInputBarState extends State<TChatInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<TherapistChatCubit>().sendText(text);
    _controller.clear();
    setState(() {});
  }

  Future<void> _attachImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (file != null && mounted) {
      context.read<TherapistChatCubit>().sendImage(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;
    final cubit = context.read<TherapistChatCubit>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cubit.replyDraft != null) _ReplyPreview(reply: cubit.replyDraft!),
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => _send(),
                              minLines: 1,
                              maxLines: 4,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.mainText,
                                fontFamily: FontFamily.tajawalRegular,
                              ),
                              decoration: InputDecoration(
                                hintText: LocaleKeys.messageHint.tr(),
                                hintStyle: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.secondaryText,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _attachImage,
                            icon: Icon(Icons.attach_file_rounded,
                                color: AppColors.secondaryText, size: 22.w),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: hasText
                        ? _send
                        : () {
                            HapticFeedback.mediumImpact();
                            cubit.sendVoice();
                          },
                    child: Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (c, a) =>
                            ScaleTransition(scale: a, child: c),
                        child: Icon(
                          hasText ? Icons.send_rounded : Icons.mic_rounded,
                          key: ValueKey(hasText),
                          color: Colors.white,
                          size: 22.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  final TReplyRef reply;
  const _ReplyPreview({required this.reply});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TherapistChatCubit>();
    final preview = switch (reply.type) {
      MsgType.voice => '🎤 ${LocaleKeys.voiceMessage.tr()}',
      MsgType.image => '📷 ${LocaleKeys.photo.tr()}',
      MsgType.text => reply.text,
    };
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 8.w, 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(10.r),
          border: const BorderDirectional(
              start: BorderSide(color: AppColors.primary, width: 3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: '${LocaleKeys.replyingTo.tr()} ${reply.sender == MsgSender.me ? LocaleKeys.you.tr() : LocaleKeys.chatWithTherapist.tr()}',
                    size: 10.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.primary,
                  ),
                  AppText(
                    text: preview,
                    size: 11.sp,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: cubit.clearReply,
              child: Icon(Icons.close_rounded,
                  size: 18.w, color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
