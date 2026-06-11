import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../shared/placeholder_home.dart';

/// الشاشة الرئيسية للمتدرّب/ولي الأمر — placeholder للمرحلة القادمة.
class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderHome(
      icon: Icons.child_care_rounded,
      color: AppColors.primary,
      roleTitle: LocaleKeys.patientRole.tr(),
    );
  }
}
