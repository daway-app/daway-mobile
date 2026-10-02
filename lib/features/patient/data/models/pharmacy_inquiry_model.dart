import '../../../../core/helpers/server_timestamp.dart';
import '../../domain/entities/pharmacy_inquiry.dart';

class PharmacyInquiryModel {
  final int id;
  final int pharmacyId;
  final int medicineId;
  final String? medicineName;
  final String? pharmacyName;
  final String message;
  final String? lastMessage;
  final int unreadCount;
  final String? reply;
  final InquiryStatus status;
  final DateTime createdAt;
  final DateTime? repliedAt;

  const PharmacyInquiryModel({
    required this.id,
    required this.pharmacyId,
    required this.medicineId,
    this.medicineName,
    this.pharmacyName,
    required this.message,
    this.lastMessage,
    this.unreadCount = 0,
    this.reply,
    required this.status,
    required this.createdAt,
    this.repliedAt,
  });

  factory PharmacyInquiryModel.fromJson(Map<String, dynamic> json) {
    final pharmacy = json['pharmacy'] as Map<String, dynamic>?;
    final medicine = json['medicine'] as Map<String, dynamic>?;
    final createdAtRaw = json['created_at'] as String?;
    final repliedAtRaw = json['replied_at'] as String?;

    return PharmacyInquiryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      pharmacyId: (pharmacy?['id'] as num?)?.toInt() ?? 0,
      medicineId: (medicine?['id'] as num?)?.toInt() ?? 0,
      medicineName: medicine?['trade_name'] as String?,
      pharmacyName: (pharmacy?['pharmacy_name'] ?? pharmacy?['name']) as String?,
      message: json['message'] as String? ?? '',
      lastMessage: _lastMessageText(json['last_message']),
      unreadCount: (json['unread_messages_count'] as num?)?.toInt() ?? 0,
      reply: json['reply'] as String?,
      status: InquiryStatus.fromApi(json['status'] as String?),
      createdAt: tryParseServerTimestamp(createdAtRaw) ?? DateTime.now(),
      repliedAt: tryParseServerTimestamp(repliedAtRaw),
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

  PharmacyInquiry toEntity() => PharmacyInquiry(
        id: id,
        pharmacyId: pharmacyId,
        medicineId: medicineId,
        medicineName: medicineName,
        pharmacyName: pharmacyName,
        message: message,
        lastMessage: lastMessage,
        unreadCount: unreadCount,
        reply: reply,
        status: status,
        createdAt: createdAt,
        repliedAt: repliedAt,
      );
}
