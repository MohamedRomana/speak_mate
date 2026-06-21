import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/di/dependancy_injection.dart';
import '../../../../../core/widgets/app_bottom_nav.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../../shared/gamification/logic/gamification_cubit.dart';
import '../../aac/logic/aac_cubit.dart';
import '../../aac/ui/aac_screen.dart';
import '../../dashboard/logic/dashboard_cubit.dart';
import '../../dashboard/ui/dashboard_screen.dart';
import '../../exercises/logic/exercises_cubit.dart';
import '../../exercises/ui/exercises_screen.dart';
import '../../notifications/logic/notifications_cubit.dart';
import '../../profile/logic/profile_cubit.dart';
import '../../profile/ui/profile_screen.dart';
import '../logic/cubit/patient_nav_cubit.dart';

/// الـ Layout الرئيسي للمتدرّب — شريط سفلي + IndexedStack للتبويبات.
/// التبويبات غير المبنية بعد تظهر كـ "قريبًا" وتُستبدل في مراحلها.
class PatientMainLayout extends StatelessWidget {
  const PatientMainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PatientNavCubit()),
        BlocProvider(create: (_) => DashboardCubit(getIt())..load()),
        BlocProvider(
          create: (_) => NotificationsCubit(getIt(), ws: getIt())..load(),
        ),
        BlocProvider(create: (_) => ExercisesCubit(getIt())..load()),
        BlocProvider(create: (_) => GamificationCubit(getIt())..load()),
        BlocProvider(create: (_) => AacCubit(getIt())..load()),
        BlocProvider(create: (_) => ProfileCubit(getIt())..load()),
      ],
      child: const _LayoutView(),
    );
  }
}

class _LayoutView extends StatelessWidget {
  const _LayoutView();

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const DashboardScreen(),
      const ExercisesScreen(),
      const AacScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: BlocBuilder<PatientNavCubit, int>(
        builder: (context, index) => IndexedStack(index: index, children: tabs),
      ),
      bottomNavigationBar: BlocBuilder<PatientNavCubit, int>(
        builder: (context, index) => AppBottomNav(
          currentIndex: index,
          onTap: (i) => context.read<PatientNavCubit>().select(i),
          items: [
            AppNavItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              label: LocaleKeys.navHome.tr(),
            ),
            AppNavItem(
              icon: Icons.sports_esports_outlined,
              activeIcon: Icons.sports_esports_rounded,
              label: LocaleKeys.navExercises.tr(),
            ),
            AppNavItem(
              icon: Icons.forum_outlined,
              activeIcon: Icons.forum_rounded,
              label: LocaleKeys.navAac.tr(),
            ),
            AppNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: LocaleKeys.navProfile.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
