import '../../../../../core/cache/cache_helper.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/networking/api_constants.dart';
import '../../../../../core/networking/api_error_model.dart';
import '../../../../../core/networking/api_result.dart';
import '../../../../../core/networking/api_service.dart';
import '../../../../auth/data/models/app_user.dart';
import '../../../../auth/data/models/user_role.dart';

/// مستودع حساب المستخدم الحالي (لكل الأدوار: أخصائي/بالغ/عيادة) — mock + API.
/// يعيد استخدام نموذج [AppUser] الموحّد. الطفل له ملفّه الخاص الأغنى (ProfileRepo).
class AccountRepo {
  final ApiService _api;
  AccountRepo({ApiService? api}) : _api = api ?? ApiService();

  Future<ApiResult<AppUser>> getAccount() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 500));
        return ApiResult.success(_mockFor(
          UserRoleX.fromKey(CacheHelper.getUserType()),
        ));
      }
      return ApiService.executeApi<AppUser>(
        () => _api.get(ApiConstants.me),
        parser: (data) => AppUser.fromJson((data as Map).cast<String, dynamic>()),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  AppUser _mockFor(UserRole role) {
    final name = CacheHelper.getUserName();
    return switch (role) {
      UserRole.therapist => AppUser(
          id: 't_1',
          name: name.isEmpty ? 'د. سارة المهدي' : name,
          email: 'sara@voicebridge.ai',
          phone: '0551112233',
          role: UserRole.therapist,
          specialty: 'اضطرابات النطق واللغة',
          licenseNumber: 'SLP-48217',
          yearsOfExperience: 9,
        ),
      UserRole.clinic => AppUser(
          id: 'c_1',
          name: name.isEmpty ? 'مركز النطق المتقدّم' : name,
          email: 'admin@advanced-speech.sa',
          phone: '0118889999',
          role: UserRole.clinic,
        ),
      UserRole.adult => AppUser(
          id: 'a_1',
          name: name.isEmpty ? 'خالد عبدالله' : name,
          email: 'khaled@example.com',
          phone: '0544445555',
          role: UserRole.adult,
          age: 54,
          difficultyType: 'difficultySpeech',
        ),
      UserRole.patient => AppUser(
          id: 'p_1',
          name: name.isEmpty ? 'أحمد محمد' : name,
          email: 'ahmed@example.com',
          phone: '0551234567',
          role: UserRole.patient,
          age: 8,
          difficultyType: 'difficultySpeech',
        ),
    };
  }
}
