import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/pharmacy_inquiry.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_inquiries_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_inquiries_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeInquiriesRepository implements PatientInquiriesRepository {
  ApiResult<List<PharmacyInquiry>> inquiriesResult = const Success([]);
  String? lastToken;

  @override
  Future<ApiResult<List<PharmacyInquiry>>> getInquiries({required String token}) async {
    lastToken = token;
    return inquiriesResult;
  }

  @override
  Future<ApiResult<PharmacyInquiry>> createInquiry({
    required String token,
    required int pharmacyId,
    int? medicineId,
    required String message,
  }) async =>
      throw UnimplementedError();
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
  test('passes the session token through to the repository', () async {
    final repository = _FakeInquiriesRepository();
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = GetPatientInquiriesUseCase(repository, sessionRepository);

    final result = await useCase();

    expect(repository.lastToken, 'tok-1');
    expect(result, isA<Success<Object?>>());
  });

  test('returns a session failure without calling the repository when logged out', () async {
    final repository = _FakeInquiriesRepository();
    final useCase = GetPatientInquiriesUseCase(repository, _FakeSessionRepository());

    final result = await useCase();

    expect(result, isA<ApiError<Object?>>());
    expect(repository.lastToken, isNull);
  });
}
