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

  const InquiryModel({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.patientName,
    this.medicineName,
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
    );
  }

  Inquiry toEntity() => Inquiry(
    id: id,
    message: message,
    status: status,
    createdAt: createdAt,
    patientName: patientName,
    medicineName: medicineName,
  );
}
