import '../../../../core/constants/api_constants.dart';
import '../../../../core/erroring/error_handler.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../../core/helpers/paginated_fetch.dart';
import '../../../auth/domain/entities/account_type.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  const ChatRepositoryImpl(this._remoteDataSource);

  /// `https://host` of the API, for resolving site-relative media paths.
  String get _host {
    final uri = Uri.parse(ApiConstants.baseUrl);
    return '${uri.scheme}://${uri.authority}';
  }

  @override
  Future<ApiResult<List<ChatMessage>>> getMessages({
    required String token,
    required AccountType accountType,
    required int inquiryId,
    bool markRead = true,
  }) async {
    try {
      final json = await fetchAllPages(
        source: 'GET .../inquiries/{id}/messages',
        fetchPage: (page) async => (await _remoteDataSource.getMessages(
          token: token,
          accountType: accountType,
          inquiryId: inquiryId,
          page: page,
          markRead: markRead,
        ))
            .data,
      );
      final messages = [
        for (final item in json)
          ChatMessageModel.fromJson(item as Map<String, dynamic>, baseHost: _host).toEntity(),
      ]..sort((a, b) {
          final byTime = a.createdAt.compareTo(b.createdAt);
          return byTime != 0 ? byTime : a.id.compareTo(b.id);
        });
      return Success(messages);
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }

  @override
  Future<ApiResult<ChatMessage>> sendMessage({
    required String token,
    required AccountType accountType,
    required int inquiryId,
    required String text,
  }) async {
    try {
      final response = await _remoteDataSource.sendText(
        token: token,
        accountType: accountType,
        inquiryId: inquiryId,
        text: text,
      );
      final body = response.data;
      final data = body is Map<String, dynamic> ? body['data'] : null;
      if (data is! Map<String, dynamic>) {
        throw FormatException('Unexpected send-message response shape: $body');
      }
      return Success(ChatMessageModel.fromJson(data, baseHost: _host).toEntity());
    } catch (e) {
      return ApiError(mapExceptionToFailure(e));
    }
  }
}
