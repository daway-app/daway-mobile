import '../../domain/entities/chat_message.dart';

sealed class ChatState {
  const ChatState();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoadFailure extends ChatState {
  final String message;

  const ChatLoadFailure(this.message);
}

class ChatLoaded extends ChatState {
  /// Oldest first.
  final List<ChatMessage> messages;
  final bool isSending;

  /// False when there is no inquiry yet and none can be started from here
  /// (a patient opening a pharmacy's chat without a medicine): the composer
  /// is hidden and a hint is shown instead.
  final bool canSend;

  const ChatLoaded(this.messages, {this.isSending = false, this.canSend = true});

  ChatLoaded copyWith({List<ChatMessage>? messages, bool? isSending, bool? canSend}) {
    return ChatLoaded(
      messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      canSend: canSend ?? this.canSend,
    );
  }
}
