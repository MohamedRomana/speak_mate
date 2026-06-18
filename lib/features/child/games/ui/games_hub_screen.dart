import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/di/dependancy_injection.dart';
import '../../../../core/helper/extentions.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../../users/patient/exercises/data/models/exercise_models.dart';
import '../../../users/patient/exercises/data/repos/exercises_repo.dart';
import '../../../users/patient/exercises/logic/exercise_player_cubit.dart';
import '../../../users/patient/exercises/ui/exercise_player_screen.dart';

/// تعريف لعبة (نوع + مرئيات + الفئة المستخدمة للون المشغّل).
class _Game {
  final GameType type;
  final String titleKey;
  final IconData icon;
  final Color color;
  final ExerciseCategory colorCategory;
  const _Game(this.type, this.titleKey, this.icon, this.color, this.colorCategory);
}

const _games = [
  _Game(GameType.repeatAi, LocaleKeys.gameRepeatAi, Icons.record_voice_over_rounded, AppColors.primary, ExerciseCategory.articulation),
  _Game(GameType.speakMatch, LocaleKeys.gameSpeakMatch, Icons.hearing_rounded, AppColors.accent, ExerciseCategory.soundMatch),
  _Game(GameType.soundGuess, LocaleKeys.gameSoundGuess, Icons.volume_up_rounded, AppColors.secondary, ExerciseCategory.soundMatch),
  _Game(GameType.pictureNaming, LocaleKeys.gamePictureNaming, Icons.image_rounded, AppColors.warning, ExerciseCategory.vocabulary),
];

/// شاشة الألعاب — أربع ألعاب نطق تفاعلية.
class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Transform.flip(
            flipX: context.locale.languageCode == 'ar',
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18.w, color: AppColors.mainText),
          ),
        ),
        title: AppText(
          text: LocaleKeys.gamesHub.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: LocaleKeys.gamesHubDesc.tr(),
              size: 13.sp,
              color: AppColors.secondaryText,
            ),
            SizedBox(height: 16.h),
            AnimationLimiter(
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14.h,
                crossAxisSpacing: 14.w,
                childAspectRatio: 0.95,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (w) => ScaleAnimation(
                    scale: 0.9,
                    child: FadeInAnimation(child: w),
                  ),
                  children:
                      _games.map((g) => _GameCard(game: g)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final _Game game;
  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22.r),
      onTap: () {
        context.pushScreen(
          BlocProvider(
            create: (_) => ExercisePlayerCubit(
              getIt<ExercisesRepo>(),
              category: game.colorCategory,
              presetItems: getIt<ExercisesRepo>().gameItems(game.type),
            )..load(),
            child: const ExercisePlayerScreen(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: game.color.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [game.color, game.color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(game.icon, color: Colors.white, size: 32.w),
            ),
            SizedBox(height: 14.h),
            AppText(
              text: game.titleKey.tr(),
              size: 14.sp,
              family: FontFamily.tajawalBold,
              color: AppColors.mainText,
              textAlign: TextAlign.center,
              lines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
