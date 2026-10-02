/// True when [text] is just a link to an uploaded image (what the chat sends
/// for a picture: the image is uploaded to Cloudinary and its link is the
/// message text).
bool isImageLink(String text) {
  final trimmed = text.trim();
  if (trimmed.contains(RegExp(r'\s'))) return false;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) return false;
  final path = uri.path.toLowerCase();
  return uri.host.endsWith('cloudinary.com') ||
      RegExp(r'\.(png|jpe?g|gif|webp)$').hasMatch(path);
}

/// How a message reads in a conversations list: a picture shows as "صورة"
/// instead of its link.
String chatPreviewText(String text) => isImageLink(text) ? 'صورة' : text;

/// One message of an inquiry thread (`.../inquiries/{id}/messages`).
class ChatMessage {
  final int id;
  final int senderUserId;
  final String text;

  /// Public URL of an image the backend stored for the message, or null.
  final String? mediaUrl;
  final bool isRead;
  final DateTime createdAt;

  /// Whether the signed-in user sent it. Not on the wire: set by
  /// [GetChatMessagesUseCase] / [SendChatMessageUseCase] from the session.
  final bool isMine;

  /// What the server says about the sender, when it says anything: an
  /// explicit `is_mine` (computed from the request's token), or the sender's
  /// role (`patient` / `pharmacy`). Preferred over guessing from user ids.
  final bool? serverIsMine;
  final String? senderRole;

  const ChatMessage({
    required this.id,
    required this.senderUserId,
    required this.text,
    this.mediaUrl,
    required this.isRead,
    required this.createdAt,
    this.isMine = false,
    this.serverIsMine,
    this.senderRole,
  });

  /// The picture this message shows, if any: an attached one, or a text that
  /// is itself an image link.
  String? get imageUrl {
    if (mediaUrl != null && mediaUrl!.isNotEmpty) return mediaUrl;
    return isImageLink(text) ? text.trim() : null;
  }

  ChatMessage copyWith({bool? isMine}) => ChatMessage(
        id: id,
        senderUserId: senderUserId,
        text: text,
        mediaUrl: mediaUrl,
        isRead: isRead,
        createdAt: createdAt,
        isMine: isMine ?? this.isMine,
        serverIsMine: serverIsMine,
        senderRole: senderRole,
      );
}
