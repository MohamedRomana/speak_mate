import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../gen/fonts.gen.dart';
import '../../generated/locale_keys.g.dart';
import 'app_button.dart';
import 'app_input.dart';
import 'app_text.dart';
import '../constants/colors.dart';

class RejectOfferSheet extends StatefulWidget {
  /// بيتنده بسبب الرفض عند الإرسال.
  final void Function(String reason) onSubmit;
  const RejectOfferSheet({super.key, required this.onSubmit});

  @override
  State<RejectOfferSheet> createState() => _RejectOfferSheetState();
}

class _RejectOfferSheetState extends State<RejectOfferSheet> {
  final reasonController = TextEditingController();

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        height: 405.h,
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 37.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AppText(
              text: LocaleKeys.price_rejection_reason.tr(),
              size: 24.sp,
              family: FontFamily.tajawalBold,
              fontWeight: FontWeight.w700,
              bottom: 28.h,
            ),
            AppInput(
              filled: true,
              inputColor: AppColors.primary,
              hint: LocaleKeys.enter_rejection_reason.tr(),
              start: 0,
              end: 0,
              color: const Color(0xffEDF0EF),
              border: 9.r,
              maxLines: 5,
              controller: reasonController,
              enabledBorderColor: Colors.transparent,
              cursorColor: AppColors.primary,
              bottom: 24.h,
            ),

            AppButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) return;
                Navigator.pop(context);
                widget.onSubmit(reason);
              },
              child: AppText(
                text: LocaleKeys.send.tr(),
                color: Colors.white,
                size: 18.sp,
                fontWeight: FontWeight.w700,
                family: FontFamily.tajawalBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
