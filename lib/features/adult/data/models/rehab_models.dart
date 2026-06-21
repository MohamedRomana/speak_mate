import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../generated/locale_keys.g.dart';

/// نوع وحدة إعادة التأهيل.
enum RehabType { slowSpeech, pronunciation, language, memory }

extension RehabTypeX on RehabType {
  String get key => name;
  static RehabType fromKey(String? k) => RehabType.values.firstWhere(
        (e) => e.name == k,
        orElse: () => RehabType.pronunciation,
      );
}

/// وحدة في برنامج إعادة التأهيل.
class RehabModule {
  final RehabType type;
  final int progress; // 0..100

  const RehabModule({required this.type, required this.progress});

  factory RehabModule.fromJson(Map<String, dynamic> json) => RehabModule(
        type: RehabTypeX.fromKey(json['type']?.toString()),
        progress: int.tryParse('${json['progress']}') ?? 0,
      );

  String get titleKey => switch (type) {
        RehabType.slowSpeech => LocaleKeys.modSlowSpeech,
        RehabType.pronunciation => LocaleKeys.modPronunciation,
        RehabType.language => LocaleKeys.modLanguage,
        RehabType.memory => LocaleKeys.modMemory,
      };

  String get descKey => switch (type) {
        RehabType.slowSpeech => LocaleKeys.modSlowSpeechDesc,
        RehabType.pronunciation => LocaleKeys.modPronunciationDesc,
        RehabType.language => LocaleKeys.modLanguageDesc,
        RehabType.memory => LocaleKeys.modMemoryDesc,
      };

  IconData get icon => switch (type) {
        RehabType.slowSpeech => Icons.slow_motion_video_rounded,
        RehabType.pronunciation => Icons.record_voice_over_rounded,
        RehabType.language => Icons.menu_book_rounded,
        RehabType.memory => Icons.psychology_alt_rounded,
      };

  Color get color => switch (type) {
        RehabType.slowSpeech => AppColors.primary,
        RehabType.pronunciation => AppColors.secondary,
        RehabType.language => AppColors.accent,
        RehabType.memory => AppColors.warning,
      };

  /// هل الوحدة تعرض الكلمة ببطء (استماع) قبل التكرار؟
  bool get isSlow => type == RehabType.slowSpeech;

  /// هل تُخفى الكلمة بعد عرضها (تمرين ذاكرة)؟
  bool get isMemory => type == RehabType.memory;
}

/// عبارة/كلمة لتمرين تأهيلي.
class RehabPhrase {
  final String text;
  const RehabPhrase(this.text);
}
