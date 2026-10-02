import '../../../../core/helpers/server_timestamp.dart';
import '../../domain/entities/chat_message.dart';

/// One entry of `PatientInquiryMessageResource`:
/// `id`, `inquiry_id`, `sender_user_id`, `message`, `media_url`,
/// `media_type`, `is_read`, `read_at`, `created_at`.
class ChatMessageModel {
  final int id;
  final int senderUserId;
  final String text;
  final String? mediaUrl;
  final bool isRead;
  final DateTime createdAt;
  final bool? serverIsMine;
  final String? senderRole;

  const ChatMessageModel({
    required this.id,
    required this.senderUserId,
    required this.text,
    this.mediaUrl,
    required this.isRead,
    required this.createdAt,
    this.serverIsMine,
    this.senderRole,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {String? baseHost}) {
    final media = json['media_url'] as String?;
    return ChatMessageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      senderUserId: (json['sender_user_id'] as num?)?.toInt() ?? 0,
      text: json['message'] as String? ?? '',
      mediaUrl: _absolute(media, baseHost),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: tryParseServerTimestamp(json['created_at'] as String?) ?? DateTime.now(),
      serverIsMine:
          json['is_mine'] == null ? null : (json['is_mine'] == true || json['is_mine'] == 1),
      senderRole: (json['sender_role'] ?? json['sender_type']) as String?,
    );
  }

  /// Points the image at the API's own host over its scheme. The server may
  /// return a site-relative path (`/storage/...`) or an absolute URL built
  /// from a misconfigured app URL (`http://localhost/...`, or plain `http`
  /// — which Android blocks), and either would not load; only the path is
  /// trusted.
  static String? _absolute(String? url, String? baseHost) {
    if (url == null || url.isEmpty) return null;
    if (baseHost == null) return url;
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    final path = uri.path.startsWith('/') ? uri.path : '/${uri.path}';
    final query = uri.hasQuery ? '?${uri.query}' : '';
    return '$baseHost$path$query';
  }

  ChatMessage toEntity() => ChatMessage(
        id: id,
        senderUserId: senderUserId,
        text: text,
        mediaUrl: mediaUrl,
        isRead: isRead,
        createdAt: createdAt,
        serverIsMine: serverIsMine,
        senderRole: senderRole,
      );
}
