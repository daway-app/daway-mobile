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

    test('a nested (non-string) error object is ignored instead of crashing the mapper', () {
      // Matches Cloudinary's unsigned-upload error shape: {"error": {"message": "..."}} —
      // json['error'] is a Map here, not a String, so the naive `as String?`
      // fallback chain must not blow up on it.
      final failure = mapExceptionToFailure(
        _badResponse(
          statusCode: 400,
          data: {
            'error': {'message': 'Upload preset not found'},
          },
        ),
      );

      expect(failure, isA<ApiFailure>());
      // The unusable body is ignored, so the status code still decides the message.
      expect(failure.message, 'يرجى التحقق من البيانات المدخلة');
    });

    test('never throws, whatever types the error body carries', () {
      // Every field the mapper reads, with every JSON type it could arrive as.
      const oddValues = <Object?>[null, 1, 1.5, true, false, 'text', <Object?>[], <String, Object?>{}];
      for (final value in oddValues) {
        for (final key in ['code', 'error_code', 'errorCode', 'message', 'error', 'msg', 'registration_required']) {
          expect(
            () => mapExceptionToFailure(_badResponse(statusCode: 422, data: {key: value})),
            returnsNormally,
            reason: '$key: $value',
          );
        }
      }
    });

    test('registration_required is honored as a boolean, 1 or "true", and is false for anything else', () {
      bool registrationRequired(Object? value) => (mapExceptionToFailure(
            _badResponse(statusCode: 422, data: {'registration_required': value}),
          ) as ApiFailure)
              .registrationRequired;

      expect(registrationRequired(true), isTrue);
      expect(registrationRequired(1), isTrue);
      expect(registrationRequired('true'), isTrue);
      expect(registrationRequired('1'), isTrue);
      expect(registrationRequired(false), isFalse);
      expect(registrationRequired(0), isFalse);
      expect(registrationRequired('yes please'), isFalse);
      expect(registrationRequired(<Object?>[]), isFalse);
      expect(registrationRequired(null), isFalse);
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
