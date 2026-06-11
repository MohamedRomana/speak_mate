import '../../../../core/constants/app_constants.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

/// مستودع المصادقة — يلفّ مصدر البيانات ويرجّع [ApiResult].
///
/// في وضع الـ mock (AppConstants.useMockData) يحاكي السيرفر بتأخير بسيط ويقبل
/// أي مدخلات صحيحة. لما يجهز الـ API الحقيقي نستبدل التنفيذ الداخلي فقط بدون
/// تغيير الـ Cubit/UI.
class AuthRepo {
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
      // TODO: نداء الـ ApiService الحقيقي هنا.
      throw UnimplementedError('Real API not wired yet');
    } catch (error) {
      return ApiResult.error(ApiErrorModel(message: error.toString()));
    }
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
      throw UnimplementedError('Real API not wired yet');
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
      throw UnimplementedError('Real API not wired yet');
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
      throw UnimplementedError('Real API not wired yet');
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
      throw UnimplementedError('Real API not wired yet');
    } catch (error) {
      return ApiResult.error(ApiErrorModel(message: error.toString()));
    }
  }

  /// تسجيل الدخول الاجتماعي (Google / Apple) — mock.
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
      throw UnimplementedError('Real API not wired yet');
    } catch (error) {
      return ApiResult.error(ApiErrorModel(message: error.toString()));
    }
  }
}
