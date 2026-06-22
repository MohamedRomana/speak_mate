import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/constants/gradients.dart';
import '../../../../../../gen/fonts.gen.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../data/models/patient_profile.dart';

/// رأس شاشة الملف: غلاف متدرّج + أفاتار + اسم + شارة الصعوبة + اكتمال الملف.
class ProfileHeader extends StatelessWidget {
  final PatientProfile profile;
  final VoidCallback onEditAvatar;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 24.h, top: 58.h),
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(32),
          bottomEnd: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 104.w,
                height: 104.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(child: _avatar()),
              ),
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: GestureDetector(
                  onTap: onEditAvatar,
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 16.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            profile.name,
            style: TextStyle(
              fontSize: 20.sp,
              fontFamily: FontFamily.tajawalBold,
              color: Colors.white,
            ),
          ),
          if (profile.difficultyType != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Text(
                profile.difficultyType!.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontFamily: FontFamily.tajawalMedium,
                ),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 22.r,
                lineWidth: 4.w,
                percent: profile.completion.clamp(0, 1),
                animation: true,
                animationDuration: 900,
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                progressColor: Colors.white,
                center: Text(
                  '${(profile.completion * 100).round()}%',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontFamily: FontFamily.tajawalBold,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                LocaleKeys.profileCompletion.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    if (profile.avatarPath != null) {
      return Image.file(
        File(profile.avatarPath!),
        width: 104.w,
        height: 104.w,
        fit: BoxFit.cover,
      );
    }
    return Container(
      color: AppColors.softPrimary,
      alignment: Alignment.center,
      child: Text(
        profile.name.isNotEmpty ? profile.name.characters.first : '🙂',
        style: TextStyle(
          fontSize: 38.sp,
          fontFamily: FontFamily.tajawalBold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
