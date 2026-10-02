import '../../../../core/helpers/api_result.dart';
import '../../../chat/domain/entities/chat_conversation.dart';
import '../../../chat/domain/entities/chat_message.dart';
import '../entities/pharmacy_inquiry.dart';
import 'get_patient_inquiries_usecase.dart';

/// The patient's conversations: one per pharmacy, however many inquiries
/// (one per medicine) they have with it, most recently active first.
class GetPharmacyConversationsUseCase implements ConversationsSource {
  final GetPatientInquiriesUseCase _getInquiriesUseCase;

  const GetPharmacyConversationsUseCase(this._getInquiriesUseCase);

  @override
  Future<ApiResult<List<ChatConversation>>> call() async {
    final result = await _getInquiriesUseCase();
    return switch (result) {
      ApiError(:final failure) => ApiError(failure),
      Success(:final data) => Success(_group(data)),
    };
  }

  List<ChatConversation> _group(List<PharmacyInquiry> inquiries) {
    final byPharmacy = <int, List<PharmacyInquiry>>{};
    for (final inquiry in inquiries) {
      byPharmacy.putIfAbsent(inquiry.pharmacyId, () => []).add(inquiry);
    }

    final groups = [
      for (final list in byPharmacy.values)
        [...list]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    ]..sort((a, b) => b.first.createdAt.compareTo(a.first.createdAt));

    return [
      for (final group in groups)
        ChatConversation(
          title: group.first.pharmacyName ?? 'صيدلية',
          lastText: chatPreviewText(
            group.first.lastMessage ?? group.first.reply ?? group.first.message,
          ),
          unreadCount: group.fold(0, (sum, i) => sum + i.unreadCount),
          inquiryIds: [for (final i in group) i.id],
          lastActivity: group.first.createdAt,
        ),
    ];
  }
}
