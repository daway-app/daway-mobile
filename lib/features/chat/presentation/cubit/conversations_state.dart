import '../../../../core/helpers/arabic_search.dart';
import '../../domain/entities/chat_conversation.dart';

sealed class ConversationsState {
  const ConversationsState();
}

class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

class ConversationsLoadFailure extends ConversationsState {
  final String message;

  const ConversationsLoadFailure(this.message);
}

class ConversationsLoaded extends ConversationsState {
  final List<ChatConversation> conversations;
  final String query;

  const ConversationsLoaded(this.conversations, {this.query = ''});

  List<ChatConversation> get visible {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return conversations;
    return conversations.where((c) => arabicContains(c.title, trimmed)).toList();
  }
}
