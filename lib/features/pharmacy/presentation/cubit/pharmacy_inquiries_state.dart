import '../../domain/entities/inquiry.dart';

sealed class PharmacyInquiriesState {
  const PharmacyInquiriesState();
}

class PharmacyInquiriesLoading extends PharmacyInquiriesState {
  const PharmacyInquiriesLoading();
}

class PharmacyInquiriesLoadFailure extends PharmacyInquiriesState {
  final String message;

  const PharmacyInquiriesLoadFailure(this.message);
}

class PharmacyInquiriesLoaded extends PharmacyInquiriesState {
  final List<Inquiry> inquiries;
  final int newCount;
  final int answeredCount;
  final int closedCount;
  final InquiryStatusFilter filter;

  /// Ids of inquiries with a status-change request in flight — disables
  /// that card's action buttons and shows a small spinner instead of
  /// letting a second tap fire a duplicate request.
  final Set<int> updatingIds;

  const PharmacyInquiriesLoaded({
    required this.inquiries,
    required this.newCount,
    required this.answeredCount,
    required this.closedCount,
    this.filter = InquiryStatusFilter.all,
    this.updatingIds = const {},
  });

  List<Inquiry> get filteredInquiries {
    final matchingStatus = switch (filter) {
      InquiryStatusFilter.all => null,
      InquiryStatusFilter.newInquiry => InquiryStatus.newInquiry,
      InquiryStatusFilter.answered => InquiryStatus.answered,
      InquiryStatusFilter.closed => InquiryStatus.closed,
    };
    if (matchingStatus == null) return inquiries;
    return inquiries.where((i) => i.status == matchingStatus).toList();
  }

  PharmacyInquiriesLoaded copyWith({
    List<Inquiry>? inquiries,
    int? newCount,
    int? answeredCount,
    int? closedCount,
    InquiryStatusFilter? filter,
    Set<int>? updatingIds,
  }) {
    return PharmacyInquiriesLoaded(
      inquiries: inquiries ?? this.inquiries,
      newCount: newCount ?? this.newCount,
      answeredCount: answeredCount ?? this.answeredCount,
      closedCount: closedCount ?? this.closedCount,
      filter: filter ?? this.filter,
      updatingIds: updatingIds ?? this.updatingIds,
    );
  }
}
