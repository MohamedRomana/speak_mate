import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/networking/api_error_model.dart';
import '../../../../../core/networking/api_result.dart';
import '../../../../../core/networking/api_service.dart';

/// مستودع الدعم — إرسال بلاغ مشكلة. mock + ربط API حقيقي خلف الفلاج.
class SupportRepo {
  final ApiService _api;
  SupportRepo({ApiService? api}) : _api = api ?? ApiService();

  Future<ApiResult<bool>> submitReport(String message) async {
    try {
      if (AppConstants.useMockData) {
        await Future.delayed(AppConstants.mockDelay);
        return const ApiResult.success(true);
      }
      return ApiService.executeApi<bool>(
        () => _api.post('support/report', data: {'message': message}),
        parser: (_) => true,
      );
    } catch (e) {
      return ApiResult.error(ApiErrorModel(message: e.toString()));
    }
  }
}
