import 'package:flutter_bloc/flutter_bloc.dart';

import '../cache/cache_helper.dart';
import '../constants/colors.dart';

/// حالة إعدادات إمكانية الوصول العامة.
class SettingsState {
  final double textScale;
  final bool highContrast;
  final bool offlineMode;
  final bool voiceCommands;

  const SettingsState({
    required this.textScale,
    required this.highContrast,
    required this.offlineMode,
    required this.voiceCommands,
  });

  SettingsState copyWith({
    double? textScale,
    bool? highContrast,
    bool? offlineMode,
    bool? voiceCommands,
  }) {
    return SettingsState(
      textScale: textScale ?? this.textScale,
      highContrast: highContrast ?? this.highContrast,
      offlineMode: offlineMode ?? this.offlineMode,
      voiceCommands: voiceCommands ?? this.voiceCommands,
    );
  }
}

/// كيوبت الإعدادات العامة — يُحقن في جذر التطبيق ويؤثّر على كامل الواجهة
/// (حجم النص عبر MediaQuery، والتباين العالي عبر [AppColors.highContrast]).
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(
          SettingsState(
            textScale: CacheHelper.getTextScale(),
            highContrast: CacheHelper.getHighContrast(),
            offlineMode: CacheHelper.getOfflineMode(),
            voiceCommands: CacheHelper.getVoiceCommands(),
          ),
        ) {
    AppColors.highContrast = state.highContrast;
  }

  void setTextScale(double value) {
    CacheHelper.setTextScale(value);
    emit(state.copyWith(textScale: value));
  }

  void setHighContrast(bool value) {
    CacheHelper.setHighContrast(value);
    AppColors.highContrast = value;
    emit(state.copyWith(highContrast: value));
  }

  void setOfflineMode(bool value) {
    CacheHelper.setOfflineMode(value);
    emit(state.copyWith(offlineMode: value));
  }

  void setVoiceCommands(bool value) {
    CacheHelper.setVoiceCommands(value);
    emit(state.copyWith(voiceCommands: value));
  }
}
