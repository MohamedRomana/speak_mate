import 'package:dio/dio.dart';

import '../../../../core/cache/cache_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/networking/api_constants.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/networking/api_service.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

/// مستودع المصادقة — يلفّ مصدر البيانات ويرجّع [ApiResult].
///
/// في وضع الـ mock (AppConstants.useMockData) يحاكي السيرفر بتأخير بسيط ويقبل
/// أي مدخلات صحيحة. عند `useMockData == false` يكلّم الـ API الحقيقي عبر
/// [ApiService] دون تغيير الـ Cubit/UI.
class AuthRepo {
  final ApiService _api;
  AuthRepo({ApiService? api}) : _api = api ?? ApiService();

  /// يستخرج المستخدم من `data` ويحفظ رمز المصادقة إن وُجد.
  Future<AppUser> _userFromData(dynamic data) async {
    final map = (data as Map).cast<String, dynamic>();
    final token = map['token']?.toString();
    if (token != null && token.isNotEmpty) {
      await CacheHelper.setAuthToken(token);
    }
    final userJson = (map['user'] ?? map).cast<String, dynamic>();
    return AppUser.fromJson(userJson);
  }
  /// تسجيل الدخول بالبريد/الجوال + كلمة المرور.
  Future<ApiResult<AppUser>> login({
    required String identifier,
    required String password,
    required UserRole role,
  }) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        final isEmail = identifier.contains('@');
        return ApiResult.success(
          AppUser(
            id: 'u_${role.key}_1',
            name: role.isTherapist ? 'د. سارة المهدي' : 'أحمد محمد',
            email: isEmail ? identifier : null,
            phone: isEmail ? null : identifier,
            role: role,
            age: role.isPatient ? 8 : null,
            difficultyType: role.isPatient ? 'difficultySpeech' : null,
            specialty: role.isTherapist ? 'اضطرابات النطق واللغة' : null,
          ),
        );
      }
      return _authCall(() => _api.post(ApiConstants.login, data: {
            'identifier': identifier,
            'password': password,
            'role': role.key,
          }));
    } catch (error) {
      return ApiResult.error(ApiErrorModel(message: error.toString()));
    }
  }

  /// ينفّذ نداء مصادقة يرجّع مستخدمًا: يفكّ الغلاف، يحفظ التوكن، ويبني [AppUser].
  Future<ApiResult<AppUser>> _authCall(
      Future<Response<dynamic>> Function() call) async {
    final raw = await ApiService.executeApi<Map<String, dynamic>>(
      call,
      parser: (data) => (data as Map).cast<String, dynamic>(),
    );
    if (raw is Failure<Map<String, dynamic>>) {
      return ApiResult.error(raw.error);
    }
    final user = await _userFromData((raw as Success<Map<String, dynamic>>).data);
    return ApiResult.success(user);
  }

  /// إنشاء حساب جديد.
  Future<ApiResult<AppUser>> register({
    required String name,
    required String identifier,
    required String password,
    required UserRole role,
    int? age,
    String? difficultyType,
    String? specialty,
    String? licenseNumber,
  }) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        final isEmail = identifier.contains('@');
        return ApiResult.success(
          AppUser(
            id: 'u_${role.key}_new',
            name: name,
            email: isEmail ? identifier : null,
            phone: isEmail ? null : identifier,
            role: role,
            age: age,
            difficultyType: difficultyType,
            specialty: specialty,
            licenseNumber: licenseNumber,
          ),
        );
      }
      return _authCall(() => _api.post(ApiConstants.register, data: {
            'name': name,
            'identifier': identifier,
            'password': password,
            'role': role.key,
            if (age != null) 'age': age,
            if (difficultyType != null) 'difficulty_type': difficultyType,
            if (specialty != null) 'specialty': specialty,
            if (licenseNumber != null) 'license_number': licenseNumber,
          }));
    } catch (error) {
      return ApiResult.error(ApiErrorModel(message: error.toString()));
    }
  }

  /// إرسال رمز التحقق لاستعادة كلمة المرور.
  Future<ApiResult<bool>> sendResetCode(String identifier) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success(true);
      }
      return ApiService.executeApi<bool>(
        () => _api.post(ApiConstants.forgot, data: {'identifier': identifier}),
        parser: (_) => true,
      );
    } catch (error) {
      return ApiResult.error(ApiErrorModel(message: error.toString()));
    }
  }

  /// التحقق من رمز OTP (في الـ mock الرمز الثابت [AppConstants.mockOtp]).
  Future<ApiResult<bool>> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        if (code == AppConstants.mockOtp) {
          return const ApiResult.success(true);
        }
        return ApiResult.error(ApiErrorModel(message: 'otpInvalid'));
      }
      return ApiService.executeApi<bool>(
        () => _api.post(ApiConstants.verifyOtp,
            data: {'identifier': identifier, 'code': code}),
        parser: (_) => true,
      );
    } catch (error) {
      return ApiResult.error(ApiErrorModel(message: error.toString()));
    }
  }

  /// تعيين كلمة مرور جديدة بعد التحقق.
  Future<ApiResult<bool>> resetPassword({
    required String identifier,
    required String newPassword,
  }) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success(true);
      }
      return ApiService.executeApi<bool>(
        () => _api.post(ApiConstants.reset,
            data: {'identifier': identifier, 'password': newPassword}),
        parser: (_) => true,
      );
    } catch (error) {
      return ApiResult.error(ApiErrorModel(message: error.toString()));
    }
  }

  /// تسجيل الدخول الاجتماعي (Google / Apple).
  Future<ApiResult<AppUser>> socialLogin({
    required String provider,
    required UserRole role,
  }) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return ApiResult.success(
          AppUser(
            id: 'u_${role.key}_$provider',
            name: role.isTherapist ? 'د. سارة المهدي' : 'مستخدم $provider',
            email: 'user@$provider.com',
            role: role,
          ),
        );
      }
      return _authCall(() => _api.post(ApiConstants.login, data: {
            'provider': provider,
            'role': role.key,
          }));
    } catch (error) {
      return ApiResult.error(ApiErrorModel(message: error.toString()));
    }
  }

  /// تسجيل الخروج: يبلّغ الخادم (إن أمكن) ويمسح رمز المصادقة محليًا.
  Future<ApiResult<bool>> logout() async {
    try {
      if (!AppConstants.useMockData) {
        await _api.post(ApiConstants.logout);
      }
      await CacheHelper.clearAuthToken();
      return const ApiResult.success(true);
    } catch (error) {
      await CacheHelper.clearAuthToken();
      return ApiResult.error(ApiErrorModel(message: error.toString()));
    }
  }
}
