import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/logic/action_state.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../data/models/aac_symbol.dart';
import '../logic/aac_cubit.dart';
import 'widgets/aac_visuals.dart';
import 'widgets/add_symbol_sheet.dart';
import 'widgets/sentence_bar.dart';

/// تبويب التواصل (AAC) — لوح رموز ديناميكي لتكوين الجُمل ونطقها.
class AacScreen extends StatelessWidget {
  const AacScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: BlocBuilder<AacCubit, ActionState>(
          builder: (context, state) {
            final cubit = context.read<AacCubit>();
            if (state is ActionLoading && cubit.currentSymbols.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            return Column(
              children: [
                _Header(cubit: cubit),
                const SentenceBar(),
                _QuickPhrases(cubit: cubit, lang: lang),
                _CategoryChips(cubit: cubit),
                Expanded(child: _SymbolGrid(cubit: cubit, lang: lang)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AacCubit cubit;
  const _Header({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 4.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: LocaleKeys.aacTitle.tr(),
                  size: 22.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.mainText,
                ),
                AppText(
                  text: LocaleKeys.aacHint.tr(),
                  size: 11.sp,
                  lines: 2,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showAddSymbolSheet(context, cubit),
            icon: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.softPrimary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.add_rounded, color: AppColors.primary, size: 24.w),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPhrases extends StatelessWidget {
  final AacCubit cubit;
  final String lang;
  const _QuickPhrases({required this.cubit, required this.lang});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: cubit.quickPhrases.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final phrase = cubit.quickPhrases[i];
          final text = phrase.map((s) => s.label(lang)).join(' ');
          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              cubit.speakPhrase(phrase);
            },
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.volume_up_rounded, size: 15.w, color: AppColors.primary),
                  SizedBox(width: 6.w),
                  AppText(
                    text: text,
                    size: 12.sp,
                    color: AppColors.mainText,
                    family: FontFamily.tajawalMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final AacCubit cubit;
  const _CategoryChips({required this.cubit});

  @override
  Widget build(BuildContext context) {
    const cats = AacCategory.values;
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        itemCount: cats.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final cat = cats[i];
          final selected = cubit.selected == cat;
          return InkWell(
            onTap: () => cubit.selectCategory(cat),
            borderRadius: BorderRadius.circular(14.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? cat.color : AppColors.card,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: selected ? cat.color : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    cat.icon,
                    size: 16.w,
                    color: selected ? Colors.white : cat.color,
                  ),
                  SizedBox(width: 6.w),
                  AppText(
                    text: cat.labelKey.tr(),
                    size: 12.sp,
                    family: FontFamily.tajawalMedium,
                    color: selected ? Colors.white : AppColors.mainText,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SymbolGrid extends StatelessWidget {
  final AacCubit cubit;
  final String lang;
  const _SymbolGrid({required this.cubit, required this.lang});

  @override
  Widget build(BuildContext context) {
    final symbols = cubit.currentSymbols;
    final isMine = cubit.selected == AacCategory.mine;
    final itemCount = symbols.length + (isMine ? 1 : 0);

    if (symbols.isEmpty && !isMine) {
      return Center(
        child: AppText(
          text: LocaleKeys.aacEmptyHint.tr(),
          color: AppColors.secondaryText,
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.85,
      ),
      itemCount: itemCount,
      itemBuilder: (context, i) {
        if (isMine && i == symbols.length) {
          return _AddTile(onTap: () => showAddSymbolSheet(context, cubit));
        }
        return _SymbolTile(
          symbol: symbols[i],
          lang: lang,
          onTap: () {
            HapticFeedback.selectionClick();
            cubit.addToSentence(symbols[i]);
          },
        );
      },
    );
  }
}

class _SymbolTile extends StatelessWidget {
  final AacSymbol symbol;
  final String lang;
  final VoidCallback onTap;
  const _SymbolTile({
    required this.symbol,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = symbol.category.color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(symbol.emoji, style: TextStyle(fontSize: 34.sp)),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: AppText(
                text: symbol.label(lang),
                size: 11.sp,
                textAlign: TextAlign.center,
                family: FontFamily.tajawalMedium,
                color: AppColors.mainText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: DottedLikeBorder(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 30.w, color: AppColors.primary),
            SizedBox(height: 4.h),
            AppText(
              text: LocaleKeys.add.tr(),
              size: 11.sp,
              color: AppColors.primary,
              family: FontFamily.tajawalMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// إطار منقّط بسيط لخانة الإضافة.
class DottedLikeBorder extends StatelessWidget {
  final Widget child;
  const DottedLikeBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softPrimary,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }
}
