import '../../domain/entities/inquiry.dart';

/// Parses one entry from `GET /pharmacy/inquiries` (confirmed against a live
/// response: `id`, `status`, `message`, `created_at`, nested `user.name`,
/// nested `medicine.trade_name`). Shared by the dashboard's recent-inquiries
/// preview and the full الاستفسارات screen so both parse the same shape once.
class InquiryModel {
  final int id;
  final String message;
  final InquiryStatus status;
  final DateTime createdAt;
  final String patientName;
  final String? medicineName;
  final int unreadCount;
  final int? patientId;
  final String? lastMessage;

  const InquiryModel({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.patientName,
    this.medicineName,
    this.unreadCount = 0,
    this.patientId,
    this.lastMessage,
  });

  factory InquiryModel.fromJson(Map<String, dynamic> json) {
    final medicine = json['medicine'] as Map<String, dynamic>?;
    final user = json['user'] as Map<String, dynamic>?;
    return InquiryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? '',
      status: inquiryStatusFrom(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      patientName: user?['name'] as String? ?? '',
      medicineName: medicine?['trade_name'] as String?,
      unreadCount: (json['unread_messages_count'] as num?)?.toInt() ?? 0,
      patientId: (user?['id'] as num?)?.toInt() ?? (json['user_id'] as num?)?.toInt(),
      lastMessage: _lastMessageText(json['last_message']),
    );
  }

  /// `last_message` may be the message text or the message object.
  static String? _lastMessageText(Object? value) {
    if (value is String) return value.isEmpty ? null : value;
    if (value is Map) {
      final text = value['message'];
      if (text is String && text.isNotEmpty) return text;
      if (value['media_url'] != null) return 'صورة';
    }
    return null;
  }

  Inquiry toEntity() => Inquiry(
    id: id,
    message: message,
    status: status,
    createdAt: createdAt,
    patientName: patientName,
    medicineName: medicineName,
    unreadCount: unreadCount,
    patientId: patientId,
    lastMessage: lastMessage,
  );
}
