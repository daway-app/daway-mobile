import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/pharmacy_inquiry.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_inquiries_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_inquiries_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_pharmacy_conversations_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

PharmacyInquiry _inquiry(int id, int minute, {String? last, String? reply, int unread = 0}) =>
    PharmacyInquiry(
      id: id,
      pharmacyId: id,
      medicineId: 6,
      pharmacyName: 'صيدلية $id',
      message: 'سؤال $id',
      lastMessage: last,
      unreadCount: unread,
      reply: reply,
      status: InquiryStatus.newInquiry,
      createdAt: DateTime(2026, 9, 30, 10, minute),
    );

class _FakeRepository implements PatientInquiriesRepository {
  List<PharmacyInquiry> inquiries = [];

  @override
  Future<ApiResult<List<PharmacyInquiry>>> getInquiries({required String token}) async =>
      Success(inquiries);

  @override
  Future<ApiResult<PharmacyInquiry>> createInquiry({
    required String token,
    required int pharmacyId,
    int? medicineId,
    required String message,
  }) =>
      throw UnimplementedError();
}

class _FakeSession implements SessionRepository {
  @override
  Future<UserSession?> getSession() async =>
      const UserSession(accountType: AccountType.patient, token: 'tok');

  @override
  Future<void> saveSession(UserSession session) async {}

  @override
  Future<void> clearSession() async {}
}

void main() {
  test('one row per pharmacy, newest first, merging its inquiries', () async {
    final repository = _FakeRepository()
      ..inquiries = [
        _inquiry(1, 1),
        _inquiry(2, 5, last: 'آخر رسالة', unread: 3),
        _inquiry(3, 3, reply: 'متوفر'),
        // A second inquiry with pharmacy 2 (same pharmacy, another medicine).
        PharmacyInquiry(
          id: 4,
          pharmacyId: 2,
          medicineId: 7,
          pharmacyName: 'صيدلية 2',
          message: 'سؤال 4',
          unreadCount: 2,
          status: InquiryStatus.newInquiry,
          createdAt: DateTime(2026, 9, 30, 10, 2),
        ),
      ];
    final useCase = GetPharmacyConversationsUseCase(
      GetPatientInquiriesUseCase(repository, _FakeSession()),
    );

    final rows = ((await useCase()) as Success).data as List;

    expect(rows, hasLength(3));
    expect(rows.map((c) => c.title), ['صيدلية 2', 'صيدلية 3', 'صيدلية 1']);
    // Pharmacy 2: newest inquiry first, latest text from it, unread summed.
    expect(rows[0].inquiryIds, [2, 4]);
    expect(rows[0].lastText, 'آخر رسالة');
    expect(rows[0].unreadCount, 5);
    expect(rows[1].lastText, 'متوفر');
    expect(rows[2].lastText, 'سؤال 1');
  });
}
