import 'package:dio/dio.dart';

import '../../../auth/domain/entities/account_type.dart';

class ChatRemoteDataSource {
  final Dio _dio;

  const ChatRemoteDataSource(this._dio);

  String _path(AccountType accountType, int inquiryId) => switch (accountType) {
        AccountType.pharmacy => '/pharmacy/inquiries/$inquiryId/messages',
        AccountType.patient => '/patient/inquiries/$inquiryId/messages',
      };

  Options _auth(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  Future<Response<dynamic>> getMessages({
    required String token,
    required AccountType accountType,
    required int inquiryId,
    required int page,
    required bool markRead,
  }) {
    return _dio.get(
      _path(accountType, inquiryId),
      queryParameters: {'page': page, if (markRead) 'mark_read': 1},
      options: _auth(token),
    );
  }

  Future<Response<dynamic>> sendText({
    required String token,
    required AccountType accountType,
    required int inquiryId,
    required String text,
  }) {
    return _dio.post(
      _path(accountType, inquiryId),
      data: {'message': text},
      options: _auth(token),
    );
  }
}
