import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speak_mate/core/networking/api_result.dart';
import 'package:speak_mate/core/networking/api_service.dart';

Response<dynamic> _resp(dynamic body, [int status = 200]) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/x'),
      data: body,
      statusCode: status,
    );

void main() {
  group('ApiService.executeApi (غلاف {key, msg, data})', () {
    test('key == 1 → Success مع تمرير data للمفسّر', () async {
      final r = await ApiService.executeApi<String>(
        () async => _resp({'key': 1, 'msg': 'ok', 'data': {'name': 'سارة'}}),
        parser: (data) => (data as Map)['name'].toString(),
      );
      expect(r.isSuccess, isTrue);
      expect((r as Success<String>).data, 'سارة');
    });

    test('key == 0 → Failure برسالة الخادم', () async {
      final r = await ApiService.executeApi<String>(
        () async => _resp({'key': 0, 'msg': 'بيانات غير صحيحة', 'data': null}),
        parser: (data) => 'unused',
      );
      expect(r.isSuccess, isFalse);
      expect((r as Failure<String>).error.message, 'بيانات غير صحيحة');
    });

    test('استثناء داخل النداء → Failure (لا يرمي)', () async {
      final r = await ApiService.executeApi<String>(
        () async => throw DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionError,
        ),
        parser: (data) => 'unused',
      );
      expect(r.isSuccess, isFalse);
    });

    test('رد بلا غلاف → يُمرَّر كما هو للمفسّر', () async {
      final r = await ApiService.executeApi<int>(
        () async => _resp([1, 2, 3]),
        parser: (data) => (data as List).length,
      );
      expect((r as Success<int>).data, 3);
    });
  });
}
