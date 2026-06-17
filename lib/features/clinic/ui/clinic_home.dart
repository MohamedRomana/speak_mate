import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../generated/locale_keys.g.dart';
import '../../users/shared/placeholder_home.dart';

/// الرئيسية لوحدة العيادة — placeholder للمرحلة القادمة.
class ClinicHomeScreen extends StatelessWidget {
  const ClinicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderHome(
      icon: Icons.local_hospital_rounded,
      color: AppColors.warning,
      roleTitle: LocaleKeys.clinicRole.tr(),
    );
  }
}
