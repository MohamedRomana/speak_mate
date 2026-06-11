import '../../../../core/constants/app_constants.dart';
import '../../../../generated/locale_keys.g.dart';

/// أدوار المستخدم في SpeakMate.
enum UserRole {
  /// المتدرّب أو ولي الأمر (يستخدم التمارين والتواصل).
  patient,

  /// أخصائي التخاطب (يدير المتدرّبين والجلسات).
  therapist,
}

extension UserRoleX on UserRole {
  /// المفتاح المخزّن في الكاش (`patient` / `therapist`).
  String get key => switch (this) {
        UserRole.patient => UserTypes.patient,
        UserRole.therapist => UserTypes.therapist,
      };

  /// مفتاح الترجمة لاسم الدور.
  String get titleKey => switch (this) {
        UserRole.patient => LocaleKeys.patientRole,
        UserRole.therapist => LocaleKeys.therapistRole,
      };

  bool get isTherapist => this == UserRole.therapist;
  bool get isPatient => this == UserRole.patient;

  /// يحوّل المفتاح المخزّن إلى Enum (الافتراضي patient).
  static UserRole fromKey(String? key) {
    return key == UserTypes.therapist ? UserRole.therapist : UserRole.patient;
  }
}
