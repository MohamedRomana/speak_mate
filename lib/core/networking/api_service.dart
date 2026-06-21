import 'package:dio/dio.dart';

import 'api_error_handler.dart';
import 'api_error_model.dart';
import 'api_result.dart';
import 'dio_factory.dart';

/// عميل HTTP رفيع فوق Dio لـ VoiceBridge، يفكّ الغلاف الموحّد `{key, msg, data}`
/// ويحوّل أي طلب إلى [ApiResult]. الـ Repos تستدعي [executeApi] فتحصل على نتيجة
/// نوعية جاهزة دون التعامل مع Dio/الأخطاء مباشرة.
class ApiService {
  final Dio _dio;
  ApiService({Dio? dio}) : _dio = dio ?? DioFactory.getDio();

  Future<Response<dynamic>> get(String path,
          {Map<String, dynamic>? query}) =>
      _dio.get(path, queryParameters: query);

  Future<Response<dynamic>> post(String path, {Object? data}) =>
      _dio.post(path, data: data);

  Future<Response<dynamic>> put(String path, {Object? data}) =>
      _dio.put(path, data: data);

  Future<Response<dynamic>> delete(String path, {Object? data}) =>
      _dio.delete(path, data: data);

  /// ينفّذ نداءً ويحوّله إلى [ApiResult] مع تفكيك الغلاف الموحّد.
  ///
  /// [parser] يحوّل `data` الناتج إلى النوع المطلوب. لو الغلاف يحمل `key == 0`
  /// تُرجَع [Failure] برسالة الخادم (`msg`).
  static Future<ApiResult<T>> executeApi<T>(
    Future<Response<dynamic>> Function() call, {
    required T Function(dynamic data) parser,
  }) async {
    try {
      final res = await call();
      final body = res.data;
      // الغلاف الموحّد: {key:1|0, msg, data}
      if (body is Map) {
        final key = body['key'];
        final ok = key == 1 || key == '1' || key == true;
        if (!ok) {
          return ApiResult.error(
            ApiErrorModel(message: body['msg']?.toString(), status: res.statusCode),
          );
        }
        return ApiResult.success(parser(body['data']));
      }
      // رد بلا غلاف (نادر) — نمرّره كما هو للمفسّر.
      return ApiResult.success(parser(body));
    } catch (error) {
      return ApiResult.error(ApiErrorHandler.handle(error));
    }
  }
}
