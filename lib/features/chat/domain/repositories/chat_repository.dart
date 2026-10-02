import '../../../../core/helpers/api_result.dart';
import '../../../auth/domain/entities/account_type.dart';
import '../entities/chat_message.dart';

/// Patient and pharmacy use the same contract on different base paths
/// (`/patient/inquiries/{id}/messages` and `/pharmacy/inquiries/{id}/messages`),
/// picked from [AccountType].
abstract class ChatRepository {
  /// Every message of the thread, oldest first. [markRead] marks the other
  /// side's messages as read (`?mark_read=1`).
  Future<ApiResult<List<ChatMessage>>> getMessages({
    required String token,
    required AccountType accountType,
    required int inquiryId,
    bool markRead = true,
  });

  /// Sends a text message (a picture is sent as its uploaded link).
  Future<ApiResult<ChatMessage>> sendMessage({
    required String token,
    required AccountType accountType,
    required int inquiryId,
    required String text,
  });
}
