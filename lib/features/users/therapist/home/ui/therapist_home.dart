import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../shared/placeholder_home.dart';

/// الشاشة الرئيسية للأخصائي — placeholder للمرحلة القادمة.
class TherapistHomeScreen extends StatelessWidget {
  const TherapistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderHome(
      icon: Icons.medical_services_rounded,
      color: AppColors.secondary,
      roleTitle: LocaleKeys.therapistRole.tr(),
    );
  }
}
