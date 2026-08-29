enum InquiryStatus { newInquiry, answered, closed }

/// Maps the backend's `new`/`answered`/`closed` status string, defaulting
/// unrecognized values to [InquiryStatus.answered] (the least
/// attention-grabbing state) rather than crashing on an unexpected string.
InquiryStatus inquiryStatusFrom(String? raw) {
  return switch (raw) {
    'new' => InquiryStatus.newInquiry,
    'closed' => InquiryStatus.closed,
    _ => InquiryStatus.answered,
  };
}

/// Inverse of [inquiryStatusFrom], for `PUT /pharmacy/inquiries/{id}`.
String inquiryStatusToWire(InquiryStatus status) {
  return switch (status) {
    InquiryStatus.newInquiry => 'new',
    InquiryStatus.answered => 'answered',
    InquiryStatus.closed => 'closed',
  };
}

/// The valid status transitions a pharmacist can trigger from the app,
/// mirroring the backend's documented flow (new → answered → closed) —
/// kept on the entity rather than in a screen/widget so any future UI that
/// lets a pharmacist act on an inquiry reuses the same rule instead of
/// reimplementing it.
extension InquiryStatusTransitions on InquiryStatus {
  bool get canMarkAnswered => this == InquiryStatus.newInquiry;

  bool get canClose => this != InquiryStatus.closed;
}

/// A patient's inquiry to the pharmacy about a medicine's availability.
/// Shared by the home screen's "أحدث الاستفسارات" preview and the full
/// الاستفسارات management screen, so both parse the same wire shape once.
class Inquiry {
  final int id;
  final String message;
  final InquiryStatus status;
  final DateTime createdAt;
  final String patientName;
  final String? medicineName;

  const Inquiry({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.patientName,
    this.medicineName,
  });
}

/// Shared by the الاستفسارات screen's filter chips and its cubit.
enum InquiryStatusFilter { all, newInquiry, answered, closed }

/// The full response shape of `GET /pharmacy/inquiries`: the page of
/// inquiries plus the backend's own status counts (`counts.new/answered/
/// closed`) — kept separate from a client-side tally of [inquiries] since
/// that list may not include every inquiry (pagination), while the counts
/// always reflect the true totals.
class InquiriesOverview {
  final List<Inquiry> inquiries;
  final int newCount;
  final int answeredCount;
  final int closedCount;

  const InquiriesOverview({
    required this.inquiries,
    required this.newCount,
    required this.answeredCount,
    required this.closedCount,
  });
}
