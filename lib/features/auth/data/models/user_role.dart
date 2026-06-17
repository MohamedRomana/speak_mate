import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../generated/locale_keys.g.dart';

/// أدوار المستخدم في VoiceBridge AI.
enum UserRole {
  /// ولي الأمر / الطفل (وحدة الطفل).
  patient,

  /// مريض بالغ (إعادة التأهيل بعد الجلطة/الأفيزيا).
  adult,

  /// أخصائي التخاطب (يدير المرضى والجلسات).
  therapist,

  /// مدير العيادة (المواعيد والسجلات والفوترة).
  clinic,
}

extension UserRoleX on UserRole {
  /// المفتاح المخزّن في الكاش.
  String get key => switch (this) {
        UserRole.patient => UserTypes.patient,
        UserRole.adult => UserTypes.adult,
        UserRole.therapist => UserTypes.therapist,
        UserRole.clinic => UserTypes.clinic,
      };

  /// مفتاح الترجمة لاسم الدور.
  String get titleKey => switch (this) {
        UserRole.patient => LocaleKeys.patientRole,
        UserRole.adult => LocaleKeys.adultRole,
        UserRole.therapist => LocaleKeys.therapistRole,
        UserRole.clinic => LocaleKeys.clinicRole,
      };

  bool get isTherapist => this == UserRole.therapist;
  bool get isPatient => this == UserRole.patient;
  bool get isAdult => this == UserRole.adult;
  bool get isClinic => this == UserRole.clinic;

  /// مسار الشاشة الرئيسية لكل دور بعد تسجيل الدخول.
  String get homeRoute => switch (this) {
        UserRole.patient => Routes.patientHome,
        UserRole.adult => Routes.adultHome,
        UserRole.therapist => Routes.therapistHome,
        UserRole.clinic => Routes.clinicHome,
      };

  /// يحوّل المفتاح المخزّن إلى Enum (الافتراضي patient).
  static UserRole fromKey(String? key) => switch (key) {
        UserTypes.adult => UserRole.adult,
        UserTypes.therapist => UserRole.therapist,
        UserTypes.clinic => UserRole.clinic,
        _ => UserRole.patient,
      };
}
