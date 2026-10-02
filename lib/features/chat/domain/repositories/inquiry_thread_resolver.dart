import '../../../../core/helpers/api_result.dart';

/// An inquiry of the patient, as far as the chat needs to know.
class InquiryRef {
  final int id;
  final int? medicineId;

  const InquiryRef({required this.id, this.medicineId});
}

/// Finds or starts the inquiries a patient chat belongs to. Implemented by
/// the patient feature (it owns `POST /patient/inquiries`); the pharmacy side
/// always opens existing inquiries, so it never needs this.
abstract class InquiryThreadResolver {
  /// Every inquiry the patient has with [pharmacyId], newest first.
  Future<ApiResult<List<InquiryRef>>> findInquiries({required int pharmacyId});

  /// Starts a new inquiry with [message] as its first message and returns its
  /// id. [medicineId] is the medicine it is about, when there is one.
  Future<ApiResult<int>> startInquiry({
    required int pharmacyId,
    int? medicineId,
    required String message,
  });
}
