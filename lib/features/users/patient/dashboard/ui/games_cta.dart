import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/helper/extentions.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../child/games/ui/games_hub_screen.dart';

/// بطاقة "الألعاب" — تفتح Games hub للطفل.
class GamesCta extends StatelessWidget {
  const GamesCta({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () => context.pushScreen(const GamesHubScreen()),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.secondary]),
              ),
              child: Icon(Icons.sports_esports_rounded,
                  color: Colors.white, size: 26.w),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: LocaleKeys.gamesHub.tr(),
                    size: 16.sp,
                    family: FontFamily.tajawalBold,
                    color: AppColors.mainText,
                  ),
                  SizedBox(height: 2.h),
                  AppText(
                    text: LocaleKeys.gamesHubDesc.tr(),
                    size: 11.sp,
                    lines: 2,
                    color: AppColors.secondaryText,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16.w, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
