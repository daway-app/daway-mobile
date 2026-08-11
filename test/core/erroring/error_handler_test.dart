import 'package:daway_app/core/erroring/error_handler.dart';
import 'package:daway_app/core/erroring/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _badResponse({int? statusCode, Map<String, dynamic>? data}) {
  final requestOptions = RequestOptions(path: '/api/login/patient');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: data,
    ),
  );
}

void main() {
  group('mapExceptionToFailure', () {
    test('prefers the server-provided message over the code map', () {
      final failure = mapExceptionToFailure(
        _badResponse(
          statusCode: 400,
          data: {'code': 'OTP_INVALID', 'message': 'رسالة مخصصة من الخادم'},
        ),
      );

      expect(failure, isA<ApiFailure>());
      expect(failure.message, 'رسالة مخصصة من الخادم');
      expect((failure as ApiFailure).code, 'OTP_INVALID');
    });

    test('falls back to the known error-code message when no server message is given', () {
      final failure = mapExceptionToFailure(
        _badResponse(statusCode: 400, data: {'code': 'OTP_EXPIRED'}),
      );

      expect(failure.message, 'انتهت صلاحية رمز التحقق، يرجى طلب رمز جديد');
    });

    test('falls back to a status-code based message when the code is unrecognized', () {
      final failure = mapExceptionToFailure(
        _badResponse(statusCode: 401, data: <String, dynamic>{}),
      );

      expect(failure.message, 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى');
    });

    test('maps connection errors to a NetworkFailure', () {
      final requestOptions = RequestOptions(path: '/api/otp/send');
      final failure = mapExceptionToFailure(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionError,
        ),
      );

      expect(failure, isA<NetworkFailure>());
    });

    test('maps non-Dio errors to an UnknownFailure', () {
      final failure = mapExceptionToFailure(Exception('boom'));

      expect(failure, isA<UnknownFailure>());
    });
  });
}
