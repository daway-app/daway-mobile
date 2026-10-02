import '../../../../core/helpers/api_result.dart';
import '../../../chat/domain/entities/chat_conversation.dart';
import '../../../chat/domain/entities/chat_message.dart';
import '../entities/inquiry.dart';
import 'get_pharmacy_inquiries_usecase.dart';

/// The pharmacy's conversations: one per patient, however many inquiries they
/// have sent, most recently active first.
class GetPatientConversationsUseCase implements ConversationsSource {
  final GetPharmacyInquiriesUseCase _getInquiriesUseCase;

  const GetPatientConversationsUseCase(this._getInquiriesUseCase);

  @override
  Future<ApiResult<List<ChatConversation>>> call() async {
    final result = await _getInquiriesUseCase();
    return switch (result) {
      ApiError(:final failure) => ApiError(failure),
      Success(:final data) => Success(_group(data.inquiries)),
    };
  }

  List<ChatConversation> _group(List<Inquiry> inquiries) {
    // The patient id when the API gives one, otherwise the name.
    final byPatient = <Object, List<Inquiry>>{};
    for (final inquiry in inquiries) {
      byPatient.putIfAbsent(inquiry.patientId ?? inquiry.patientName, () => []).add(inquiry);
    }

    final groups = [
      for (final list in byPatient.values)
        [...list]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    ]..sort((a, b) => b.first.createdAt.compareTo(a.first.createdAt));

    return [
      for (final group in groups)
        ChatConversation(
          title: group.first.patientName.isEmpty ? 'مريض' : group.first.patientName,
          lastText: chatPreviewText(group.first.lastMessage ?? group.first.message),
          unreadCount: group.fold(0, (sum, i) => sum + i.unreadCount),
          inquiryIds: [for (final i in group) i.id],
          lastActivity: group.first.createdAt,
        ),
    ];
  }
}
