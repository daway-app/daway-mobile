import '../../../../core/helpers/api_result.dart';

/// One row of an inquiries list: everything the signed-in user has exchanged
/// with one other party. The backend keeps a separate inquiry per medicine
/// (and per fresh start), so a party can own several — they are grouped here
/// into a single conversation, and the chat merges their messages.
class ChatConversation {
  /// The other party: a pharmacy's name for a patient, a patient's name for a
  /// pharmacy.
  final String title;

  /// The latest text (or, failing that, the opening question).
  final String lastText;
  final int unreadCount;

  /// Every inquiry of this conversation, newest first.
  final List<int> inquiryIds;

  final DateTime lastActivity;

  const ChatConversation({
    required this.title,
    required this.lastText,
    this.unreadCount = 0,
    required this.inquiryIds,
    required this.lastActivity,
  });
}

/// A source of [ChatConversation]s — implemented by a use case per side.
abstract class ConversationsSource {
  Future<ApiResult<List<ChatConversation>>> call();
}
