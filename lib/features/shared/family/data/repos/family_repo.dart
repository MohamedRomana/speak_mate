import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/networking/api_constants.dart';
import '../../../../../core/networking/api_error_model.dart';
import '../../../../../core/networking/api_result.dart';
import '../../../../../core/networking/api_service.dart';
import '../models/child_profile.dart';

/// مستودع الأطفال (الباقة العائلية) — عرض/إضافة/تبديل النشط. mock + API.
class FamilyRepo {
  final ApiService _api;
  FamilyRepo({ApiService? api}) : _api = api ?? ApiService();

  /// أقصى عدد أطفال في الباقة العائلية.
  static const maxChildren = 4;

  Future<ApiResult<List<ChildProfile>>> getChildren() async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 600));
        return const ApiResult.success(_children);
      }
      return ApiService.executeApi<List<ChildProfile>>(
        () => _api.get('${ApiConstants.me}/children'),
        parser: (data) => (data as List)
            .map((e) => ChildProfile.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  Future<ApiResult<ChildProfile>> addChild({
    required String name,
    required int age,
    required String difficultyType,
    required String emoji,
  }) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return ApiResult.success(ChildProfile(
          id: 'c_${name.hashCode.abs()}',
          name: name,
          age: age,
          emoji: emoji,
          difficultyType: difficultyType,
        ));
      }
      return ApiService.executeApi<ChildProfile>(
        () => _api.post('${ApiConstants.me}/children', data: {
          'name': name,
          'age': age,
          'difficulty_type': difficultyType,
          'emoji': emoji,
        }),
        parser: (data) =>
            ChildProfile.fromJson((data as Map).cast<String, dynamic>()),
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  /// تعيين الطفل النشط (الذي تُعرض بياناته في التطبيق).
  Future<ApiResult<bool>> setActive(String childId) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(const Duration(milliseconds: 400));
        return const ApiResult.success(true);
      }
      return ApiService.executeApi<bool>(
        () => _api.put('${ApiConstants.me}/children/$childId/active'),
        parser: (_) => true,
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }

  static const _children = [
    ChildProfile(
        id: 'c1',
        name: 'أحمد',
        age: 8,
        emoji: '👦',
        difficultyType: 'difficultySpeech',
        progress: 78),
    ChildProfile(
        id: 'c2',
        name: 'سارة',
        age: 6,
        emoji: '👧',
        difficultyType: 'difficultyArticulation',
        progress: 45),
  ];
}
