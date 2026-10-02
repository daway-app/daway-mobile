import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/pharmacy_inquiry.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_inquiries_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/create_patient_inquiry_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

final _created = PharmacyInquiry(
  id: 1,
  pharmacyId: 1,
  medicineId: 6,
  message: 'هل يتوفر؟',
  status: InquiryStatus.newInquiry,
  createdAt: DateTime(2026, 9, 29),
);

class _FakeInquiriesRepository implements PatientInquiriesRepository {
  ApiResult<PharmacyInquiry> createResult = Success(_created);
  String? lastToken;
  int? lastPharmacyId;
  int? lastMedicineId;
  String? lastMessage;

  @override
  Future<ApiResult<List<PharmacyInquiry>>> getInquiries({required String token}) async =>
      const Success([]);

  @override
  Future<ApiResult<PharmacyInquiry>> createInquiry({
    required String token,
    required int pharmacyId,
    int? medicineId,
    required String message,
  }) async {
    lastToken = token;
    lastPharmacyId = pharmacyId;
    lastMedicineId = medicineId;
    lastMessage = message;
    return createResult;
  }
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession;

  @override
  Future<void> saveSession(UserSession session) async => savedSession = session;

  @override
  Future<UserSession?> getSession() async => savedSession;

  @override
  Future<void> clearSession() async => savedSession = null;
}

void main() {
  test('passes the session token, pharmacy id, medicine id and message through', () async {
    final repository = _FakeInquiriesRepository();
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = CreatePatientInquiryUseCase(repository, sessionRepository);

    final result = await useCase(pharmacyId: 1, medicineId: 6, message: 'هل يتوفر؟');

    expect(repository.lastToken, 'tok-1');
    expect(repository.lastPharmacyId, 1);
    expect(repository.lastMedicineId, 6);
    expect(repository.lastMessage, 'هل يتوفر؟');
    expect(result, isA<Success<PharmacyInquiry>>());
  });

  test('returns a session failure without calling the repository when logged out', () async {
    final repository = _FakeInquiriesRepository();
    final useCase = CreatePatientInquiryUseCase(repository, _FakeSessionRepository());

    final result = await useCase(pharmacyId: 1, medicineId: 6, message: 'هل يتوفر؟');

    expect(result, isA<ApiError<PharmacyInquiry>>());
    expect(repository.lastPharmacyId, isNull);
  });
}
