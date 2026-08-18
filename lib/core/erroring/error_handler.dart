import 'package:dio/dio.dart';

import 'api_error_model.dart';
import 'failure.dart';

const String _genericErrorMessage = 'حدث خطأ ما، يرجى المحاولة لاحقاً';

Failure mapExceptionToFailure(Object error) {
  if (error is DioException) {
    return _mapDioException(error);
  }
  return const UnknownFailure(_genericErrorMessage);
}

Failure _mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkFailure('انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى');
    case DioExceptionType.connectionError:
      return const NetworkFailure('تعذر الاتصال بالخادم، تحقق من اتصالك بالإنترنت');
    case DioExceptionType.cancel:
      return const UnknownFailure('تم إلغاء الطلب');
    case DioExceptionType.badResponse:
      return _mapBadResponse(error);
    default:
      return const NetworkFailure('تعذر الاتصال بالخادم، تحقق من اتصالك بالإنترنت');
  }
}

Failure _mapBadResponse(DioException error) {
  final statusCode = error.response?.statusCode;
  final responseData = error.response?.data;

  final apiError = responseData is Map<String, dynamic>
      ? ApiErrorModel.fromJson(responseData)
      : null;

  final serverMessage = apiError?.message;
  final message = _arabicMessageForCode(apiError?.code) ??
      _arabicMessageForServerText(serverMessage) ??
      (serverMessage != null && _looksArabic(serverMessage) ? serverMessage : null) ??
      _arabicMessageForStatusCode(statusCode) ??
      serverMessage ??
      _genericErrorMessage;

  return ApiFailure(
    message: message,
    code: apiError?.code,
    statusCode: statusCode,
  );
}

/// Maps a known backend error [code] to a user-friendly Arabic message.
/// Returns null when the code is unrecognized (or absent), so callers can
/// fall back to the server-provided message or a status-code based one.
String? _arabicMessageForCode(String? code) {
  switch (code) {
    case 'VALIDATION_ERROR':
      return 'يرجى التحقق من البيانات المدخلة';
    case 'UNAUTHORIZED':
      return 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى';
    case 'FORBIDDEN':
      return 'ليس لديك صلاحية للقيام بهذا الإجراء';
    case 'PHONE_EXISTS':
      return 'رقم الجوال مسجل مسبقاً';
    case 'INVALID_CREDENTIALS':
      return 'بيانات الدخول غير صحيحة';
    case 'OTP_INVALID':
      return 'رمز التحقق غير صحيح';
    case 'OTP_EXPIRED':
      return 'انتهت صلاحية رمز التحقق، يرجى طلب رمز جديد';
    case 'TOKEN_EXPIRED':
      return 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';
    case 'ACCOUNT_INACTIVE':
      return 'حسابك غير مفعّل، يرجى التواصل مع الدعم';
  }
  return null;
}

final RegExp _arabicScript = RegExp(r'[؀-ۿ]');

/// Whether [text] contains Arabic script, used to decide whether a raw
/// server message is safe to show as-is instead of an English leak.
bool _looksArabic(String text) => _arabicScript.hasMatch(text);

/// Maps known raw (usually English) server messages to a precise Arabic
/// message, for backends that don't send an error [code] at all. Returns
/// null when the text doesn't match a known phrase.
String? _arabicMessageForServerText(String? message) {
  if (message == null) return null;
  final normalized = message.toLowerCase();

  if (normalized.contains('otp')) {
    if (normalized.contains('expired')) {
      return normalized.contains('invalid')
          ? 'رمز التحقق غير صحيح أو منتهي الصلاحية'
          : 'انتهت صلاحية رمز التحقق، يرجى طلب رمز جديد';
    }
    if (normalized.contains('invalid') || normalized.contains('incorrect')) {
      return 'رمز التحقق غير صحيح';
    }
  }

  return null;
}

/// Maps an HTTP status code to a generic Arabic message, used only when
/// neither a known error code nor a server message is available.
String? _arabicMessageForStatusCode(int? statusCode) {
  switch (statusCode) {
    case 400:
    case 422:
      return 'يرجى التحقق من البيانات المدخلة';
    case 401:
      return 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى';
    case 403:
      return 'ليس لديك صلاحية للقيام بهذا الإجراء';
    case 404:
      return 'الخدمة المطلوبة غير متوفرة';
    case 429:
      return 'محاولات كثيرة، يرجى المحاولة لاحقاً';
    case 500:
    case 502:
    case 503:
      return 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً';
  }
  return null;
}
