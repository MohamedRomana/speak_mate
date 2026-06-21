import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../cache/cache_helper.dart';
import 'api_constants.dart';

class DioFactory {
  DioFactory._();

  static Dio? dio;

  static Dio getDio() {
    Duration timeOut = const Duration(seconds: 30);

    if (dio == null) {
      dio = Dio();
      dio!
        ..options.baseUrl = ApiConstants.baseUrl
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut
        ..options.headers['Accept'] = 'application/json'
        ..options.validateStatus = (status) {
          return status != null && status < 500; // أي كود <500 يقبله
        };
      getDioInterceptors();
      return dio!;
    } else {
      return dio!;
    }
  }

  static void getDioInterceptors() {
    // يحقن رمز المصادقة (Bearer) ولغة العميل في كل طلب تلقائيًا.
    dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = CacheHelper.getAuthToken();
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final lang = CacheHelper.getLang();
          if (lang.isNotEmpty) options.headers['Accept-Language'] = lang;
          handler.next(options);
        },
      ),
    );
    dio!.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }
}
