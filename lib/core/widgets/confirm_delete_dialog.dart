import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../gen/assets.gen.dart';
import '../../generated/locale_keys.g.dart';
import '../../gen/fonts.gen.dart';
import '../constants/colors.dart';
import 'app_text.dart';

/// ديالوج تأكيد حذف عام يستخدم في كل التطبيق.
/// [onConfirm] لازم ترجّع Future — الديالوج بيفضل مفتوح ويعرض لوتي تحميل
/// لحد ما العملية تخلص، وبعدها بيتقفل تلقائياً.
class ConfirmDeleteDialog extends StatefulWidget {
  final Future<void> Function() onConfirm;
  final String? message;
  const ConfirmDeleteDialog({super.key, required this.onConfirm, this.message});

  /// طريقة سريعة للعرض.
  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onConfirm,
    String? message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          ConfirmDeleteDialog(onConfirm: onConfirm, message: message),
    );
  }

  @override
  State<ConfirmDeleteDialog> createState() => _ConfirmDeleteDialogState();
}

class _ConfirmDeleteDialogState extends State<ConfirmDeleteDialog> {
  bool _loading = false;

  Future<void> _onConfirm() async {
    setState(() => _loading = true);
    await widget.onConfirm();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Lottie.asset(Assets.img.loading, height: 150.w, width: 150.w)
        : AlertDialog(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
            title: Column(
              children: [
                Image.asset(
                  Assets.img.logo.path,
                  height: 60.w,
                  width: 60.w,
                  fit: BoxFit.fill,
                ),
                AppText(
                  top: 16.h,
                  text: widget.message ?? LocaleKeys.confirm_delete.tr(),
                  size: 16.sp,
                  family: FontFamily.tajawalBold,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ],
            ),
            actions: _loading
                ? null
                : [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: AppText(
                        text: LocaleKeys.cancel.tr(),
                        size: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: _onConfirm,
                      child: AppText(
                        text: LocaleKeys.delete.tr(),
                        size: 14.sp,
                        color: Colors.red,
                        family: FontFamily.tajawalBold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
          );
  }
}
