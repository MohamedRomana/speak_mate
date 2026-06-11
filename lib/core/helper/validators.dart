import 'package:easy_localization/easy_localization.dart';

import '../constants/app_constants.dart';
import '../../generated/locale_keys.g.dart';

/// تحقّقات موحّدة برسائل عربية — تُستخدم في كل الفورمات.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static String? required(String? value, {String? message}) {
    if (value == null || value.trim().isEmpty) {
      return message ?? LocaleKeys.please.tr();
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.fullNameRequired.tr();
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.phoneRequired.tr();
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.emailRequired.tr();
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return LocaleKeys.emailInvalid.tr();
    }
    return null;
  }

  static String? phoneOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.phoneOrEmailValidate.tr();
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.passwordValidate.tr();
    }
    if (value.length < AppConstants.minPasswordLength) {
      return LocaleKeys.passwordMin8.tr();
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) {
      return LocaleKeys.passwordsNotMatch.tr();
    }
    return null;
  }
}

/// مستويات قوة كلمة المرور.
enum PasswordStrength { weak, medium, strong }

extension PasswordStrengthHelper on String {
  PasswordStrength get passwordStrength {
    var score = 0;
    if (length >= 8) score++;
    if (length >= 12) score++;
    if (contains(RegExp(r'[A-Z]')) && contains(RegExp(r'[a-z]'))) score++;
    if (contains(RegExp(r'[0-9]'))) score++;
    if (contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) score++;
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}
