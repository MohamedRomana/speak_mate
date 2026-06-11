import 'package:freezed_annotation/freezed_annotation.dart';
import 'api_error_model.dart';
part 'api_result.freezed.dart';

@Freezed()
class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success(T data) = Success<T>;
  const factory ApiResult.error(ApiErrorModel error) = Failure<T>;
}

/// اختصارات مساعدة على [ApiResult]. ملاحظة: `.when` / `.map` متوفّرة أصلاً من
/// Freezed 3 (extension ApiResultPatterns)، فلا نعيد تعريفها هنا تفاديًا للتعارض.
extension ApiResultX<T> on ApiResult<T> {
  bool get isSuccess => this is Success<T>;

  /// البيانات عند النجاح أو null.
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
}
