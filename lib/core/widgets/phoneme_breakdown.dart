import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../services/phoneme_analyzer.dart';
import '../../gen/fonts.gen.dart';
import '../../generated/locale_keys.g.dart';
import 'app_text.dart';

/// تفكيك النطق إلى أصوات: رقاقة ملوّنة لكل فونيم (أخضر صحيح / كهرماني تشويه /
/// أحمر محذوف أو مُبدَل). ودجت مشتركة بين "تحدّث مع AI" ومشغّل التمارين وجلسات
/// الكبار — تجسّد كشف الأخطاء على مستوى الصوت (لب محرّك الكلام).
class PhonemeBreakdown extends StatelessWidget {
  final SpeechAnalysis analysis;
  final bool showTitle;
  const PhonemeBreakdown({super.key, required this.analysis, this.showTitle = true});

  @override
  Widget build(BuildContext context) {
    final chips = analysis.phonemes
        .where((p) => p.expected.isNotEmpty || p.error == PhonemeError.extra)
        .toList();
    if (chips.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          AppText(
            text: LocaleKeys.soundBreakdown.tr(),
            size: 12.sp,
            family: FontFamily.tajawalBold,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: 8.h),
        ],
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          children: chips.map(_chip).toList(),
        ),
      ],
    );
  }

  Widget _chip(PhonemeResult p) {
    final (color, icon) = switch (p.error) {
      PhonemeError.correct => (AppColors.success, Icons.check_rounded),
      PhonemeError.distorted => (AppColors.warning, Icons.change_history_rounded),
      PhonemeError.missing => (AppColors.error, Icons.remove_rounded),
      PhonemeError.substituted => (AppColors.error, Icons.swap_horiz_rounded),
      PhonemeError.extra => (AppColors.secondaryText, Icons.add_rounded),
    };
    final glyph = p.expected.isNotEmpty ? p.expected : (p.actual ?? '');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.w, color: color),
          SizedBox(width: 4.w),
          AppText(
            text: glyph,
            size: 14.sp,
            family: FontFamily.tajawalBold,
            color: color,
          ),
        ],
      ),
    );
  }
}
