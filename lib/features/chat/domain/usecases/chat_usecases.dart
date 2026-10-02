import '../../../../core/erroring/failure.dart';
import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/entities/account_type.dart';
import '../../../auth/domain/entities/user_session.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_image_uploader.dart';
import '../repositories/chat_repository.dart';

const _sessionExpired = ApiFailure(message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى');

class GetChatMessagesUseCase {
  final ChatRepository _repository;
  final SessionRepository _sessionRepository;

  const GetChatMessagesUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<List<ChatMessage>>> call(int inquiryId, {bool markRead = true}) async {
    final session = await _sessionRepository.getSession();
    if (session == null) return const ApiError(_sessionExpired);

    final result = await _repository.getMessages(
      token: session.token,
      accountType: session.accountType,
      inquiryId: inquiryId,
      markRead: markRead,
    );
    return switch (result) {
      ApiError() => result,
      Success(:final data) => Success(_markMine(data, session)),
    };
  }

  /// A message is mine when, in order of preference: the server says so
  /// (`is_mine`), or names the sender's role and it is mine; the sender is the
  /// signed-in user id; or — as the last resort — by the thread's shape: it
  /// always opens with the patient's question, so the first message's sender
  /// is the patient.
  List<ChatMessage> _markMine(List<ChatMessage> messages, UserSession session) {
    if (messages.isEmpty) return messages;
    final userId = session.userId;
    final patientId = messages.first.senderUserId;
    return [
      for (final message in messages)
        message.copyWith(
          isMine: message.serverIsMine ??
              (message.senderRole != null
                  ? message.senderRole == session.accountType.name
                  : userId != null
                      ? message.senderUserId == userId
                      : (session.accountType == AccountType.patient
                          ? message.senderUserId == patientId
                          : message.senderUserId != patientId)),
        ),
    ];
  }
}

class SendChatMessageUseCase {
  final ChatRepository _repository;
  final SessionRepository _sessionRepository;

  const SendChatMessageUseCase(this._repository, this._sessionRepository);

  Future<ApiResult<ChatMessage>> call(int inquiryId, String text) async {
    final session = await _sessionRepository.getSession();
    if (session == null) return const ApiError(_sessionExpired);

    final result = await _repository.sendMessage(
      token: session.token,
      accountType: session.accountType,
      inquiryId: inquiryId,
      text: text,
    );
    return switch (result) {
      ApiError() => result,
      // A message I just sent is mine by definition.
      Success(:final data) => Success(data.copyWith(isMine: true)),
    };
  }
}

/// Uploads a picked image and returns the link that is then sent as a message.
class UploadChatImageUseCase {
  final ChatImageUploader _uploader;

  const UploadChatImageUseCase(this._uploader);

  Future<ApiResult<String>> call(String imagePath) => _uploader.upload(imagePath);
}
