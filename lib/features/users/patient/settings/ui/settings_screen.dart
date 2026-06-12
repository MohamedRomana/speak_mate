import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/cache/cache_helper.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/helper/extentions.dart';
import '../../../../../core/logic/settings_cubit.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../core/widgets/flash_message.dart';
import '../../../../../gen/fonts.gen.dart';
import '../../../../../generated/locale_keys.g.dart';

/// شاشة الإعدادات وإمكانية الوصول.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          text: LocaleKeys.settings.tr(),
          size: 17.sp,
          family: FontFamily.tajawalBold,
          color: AppColors.mainText,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              title: LocaleKeys.appearance.tr(),
              icon: Icons.palette_outlined,
              child: Column(
                children: [
                  const _ThemeSelector(),
                  SizedBox(height: 16.h),
                  const _LanguageSelector(),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _SectionCard(
              title: LocaleKeys.accessibility.tr(),
              icon: Icons.accessibility_new_rounded,
              child: const Column(
                children: [
                  _TextSizeControl(),
                  _HighContrastToggle(),
                  _VoiceCommandsToggle(),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _SectionCard(
              title: LocaleKeys.offlineMode.tr(),
              icon: Icons.cloud_off_rounded,
              child: const _OfflineSection(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.w, color: AppColors.primary),
              SizedBox(width: 8.w),
              AppText(
                text: title,
                size: 15.sp,
                family: FontFamily.tajawalBold,
                color: AppColors.mainText,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final cubit = context.read<ThemeCubit>();
        Widget seg(String label, IconData icon, ThemeMode m) {
          final sel = mode == m;
          return Expanded(
            child: GestureDetector(
              onTap: () => cubit.setMode(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: sel ? AppColors.softPrimary : AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: sel ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon,
                        size: 20.w,
                        color: sel ? AppColors.primary : AppColors.secondaryText),
                    SizedBox(height: 4.h),
                    AppText(
                      text: label,
                      size: 11.sp,
                      color: sel ? AppColors.primary : AppColors.secondaryText,
                      family: FontFamily.tajawalMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Row(
          children: [
            seg(LocaleKeys.themeLight.tr(), Icons.light_mode_rounded,
                ThemeMode.light),
            seg(LocaleKeys.themeDark.tr(), Icons.dark_mode_rounded,
                ThemeMode.dark),
            seg(LocaleKeys.themeSystem.tr(), Icons.brightness_auto_rounded,
                ThemeMode.system),
          ],
        );
      },
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    Future<void> setLang(String code) async {
      await CacheHelper.setLang(code);
      if (context.mounted) await context.setLocale(Locale(code));
    }

    Widget btn(String label, String code, bool sel) => Expanded(
          child: GestureDetector(
            onTap: () => setLang(code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.scaffoldBg,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: sel ? AppColors.primary : AppColors.border,
                ),
              ),
              child: AppText(
                text: label,
                size: 13.sp,
                family: FontFamily.tajawalBold,
                color: sel ? Colors.white : AppColors.secondaryText,
              ),
            ),
          ),
        );

    return Row(
      children: [
        btn('العربية', 'ar', isAr),
        btn('English', 'en', !isAr),
      ],
    );
  }
}

class _TextSizeControl extends StatelessWidget {
  const _TextSizeControl();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppText(
                  text: LocaleKeys.textSize.tr(),
                  size: 14.sp,
                  family: FontFamily.tajawalMedium,
                  color: AppColors.mainText,
                ),
                const Spacer(),
                AppText(
                  text: '${(state.textScale * 100).round()}%',
                  size: 12.sp,
                  family: FontFamily.tajawalBold,
                  color: AppColors.primary,
                ),
              ],
            ),
            Row(
              children: [
                Text('أ', style: TextStyle(fontSize: 13.sp, color: AppColors.secondaryText)),
                Expanded(
                  child: Slider(
                    value: state.textScale,
                    min: 0.85,
                    max: 1.4,
                    divisions: 11,
                    activeColor: AppColors.primary,
                    onChanged: (v) =>
                        context.read<SettingsCubit>().setTextScale(v),
                  ),
                ),
                Text('أ', style: TextStyle(fontSize: 22.sp, color: AppColors.secondaryText)),
              ],
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: AppText(
                text: LocaleKeys.settingsPreview.tr(),
                size: 14.sp,
                lines: 2,
                color: AppColors.mainText,
              ),
            ),
            SizedBox(height: 8.h),
          ],
        );
      },
    );
  }
}

class _HighContrastToggle extends StatelessWidget {
  const _HighContrastToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) => _ToggleTile(
        icon: Icons.contrast_rounded,
        title: LocaleKeys.highContrast.tr(),
        subtitle: LocaleKeys.highContrastDesc.tr(),
        value: state.highContrast,
        onChanged: (v) => context.read<SettingsCubit>().setHighContrast(v),
      ),
    );
  }
}

class _VoiceCommandsToggle extends StatelessWidget {
  const _VoiceCommandsToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) => _ToggleTile(
        icon: Icons.keyboard_voice_outlined,
        title: LocaleKeys.voiceCommands.tr(),
        subtitle: LocaleKeys.voiceCommandsDesc.tr(),
        value: state.voiceCommands,
        onChanged: (v) => context.read<SettingsCubit>().setVoiceCommands(v),
      ),
    );
  }
}

class _OfflineSection extends StatelessWidget {
  const _OfflineSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            _ToggleTile(
              icon: Icons.wifi_off_rounded,
              title: LocaleKeys.offlineMode.tr(),
              subtitle: LocaleKeys.offlineModeDesc.tr(),
              value: state.offlineMode,
              onChanged: (v) => context.read<SettingsCubit>().setOfflineMode(v),
            ),
            SizedBox(height: 6.h),
            GestureDetector(
              onTap: () => showFlashMessage(
                message: LocaleKeys.downloadStarted.tr(),
                type: FlashMessageType.success,
                context: context,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.softPrimary,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded,
                        size: 18.w, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    AppText(
                      text: LocaleKeys.downloadContent.tr(),
                      size: 13.sp,
                      family: FontFamily.tajawalBold,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 22.w, color: AppColors.secondaryText),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  size: 14.sp,
                  family: FontFamily.tajawalMedium,
                  color: AppColors.mainText,
                ),
                AppText(
                  text: subtitle,
                  size: 11.sp,
                  lines: 2,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
