import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../generated/locale_keys.g.dart';
import '../../users/shared/placeholder_home.dart';

/// الرئيسية لوحدة الكبار (إعادة التأهيل) — placeholder للمرحلة القادمة.
class AdultHomeScreen extends StatelessWidget {
  const AdultHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderHome(
      icon: Icons.elderly_rounded,
      color: AppColors.secondary,
      roleTitle: LocaleKeys.adultRole.tr(),
    );
  }
}
