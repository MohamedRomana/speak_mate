import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_icons.dart';
import '../constants/colors.dart';
import '../../gen/fonts.gen.dart';
import '../../generated/locale_keys.g.dart';
import 'app_svg_icon.dart';
import 'fade_slide_in.dart';

/// Bottom sheet متحرّك لاختيار مصدر الصورة (الكاميرا / المعرض).
class ImageSourceSheet extends StatelessWidget {
  const ImageSourceSheet({super.key});

  static Future<ImageSource?> show(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const ImageSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            LocaleKeys.selectImageSourceTitle.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.mainText,
              fontFamily: FontFamily.tajawalBold,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: FadeSlideIn(
                  from: SlideFrom.start,
                  child: _SourceOption(
                    icon: AppIcons.camera,
                    label: LocaleKeys.cameraWord.tr(),
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  from: SlideFrom.end,
                  child: _SourceOption(
                    icon: AppIcons.gallery,
                    label: LocaleKeys.galleryWord.tr(),
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
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

class _SourceOption extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.lightBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                color: AppColors.softOrange,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppSvgIcon(assetPath: icon, size: 26.w, color: AppColors.orange),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.mainText,
                fontFamily: FontFamily.tajawalBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
