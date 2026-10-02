enum InquiryStatus {
  newInquiry,
  answered,
  closed;

  static InquiryStatus fromApi(String? value) => switch (value) {
        'new' => InquiryStatus.newInquiry,
        'answered' => InquiryStatus.answered,
        'closed' => InquiryStatus.closed,
        _ => InquiryStatus.newInquiry,
      };
}

/// A patient's question to a pharmacy about one medicine ("اسأل الصيدلية قبل
/// الشراء"), and the pharmacy's answer once they respond — this is a single
/// question/reply pair, not a live back-and-forth thread (the backend has no
/// endpoint for the pharmacy to send more than one [reply] per inquiry).
class PharmacyInquiry {
  final int id;
  final int pharmacyId;
  final int medicineId;

  /// From the nested `medicine.trade_name`; null when the API omits it.
  final String? medicineName;

  /// From the nested `pharmacy.pharmacy_name` (or `name`); null when omitted.
  final String? pharmacyName;
  final String message;

  /// The thread's latest chat message text and how many of the pharmacy's
  /// messages the patient hasn't read (`last_message`, `unread_messages_count`).
  final String? lastMessage;
  final int unreadCount;
  final String? reply;
  final InquiryStatus status;
  final DateTime createdAt;
  final DateTime? repliedAt;

  const PharmacyInquiry({
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
}
