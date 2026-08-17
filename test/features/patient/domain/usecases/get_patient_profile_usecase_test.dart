import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/patient_profile.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_profile_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePatientProfileRepository implements PatientProfileRepository {
  String? lastToken;
  ApiResult<PatientProfile> result = const Success(
    PatientProfile(name: 'أحمد محمد', phone: '0599123456'),
  );

  @override
  Future<ApiResult<PatientProfile>> getProfile({required String token}) async {
    lastToken = token;
    return result;
  }

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PatientProfile profile,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession;

  @override
  Future<void> saveSession(UserSession session) async {
    savedSession = session;
  }

  @override
  Future<UserSession?> getSession() async => savedSession;

  @override
  Future<void> clearSession() async {
    savedSession = null;
  }
}

void main() {
  late _FakePatientProfileRepository repository;
  late _FakeSessionRepository sessionRepository;
  late GetPatientProfileUseCase useCase;

  setUp(() {
    repository = _FakePatientProfileRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = GetPatientProfileUseCase(repository, sessionRepository);
  });

  test('fails without hitting the repository when there is no saved session', () async {
    final result = await useCase();

    expect(result, isA<ApiError<PatientProfile>>());
    expect(repository.lastToken, isNull);
  });

  test('fetches the profile using the saved session token', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.patient, token: 'tok-789');

    final result = await useCase();

    expect(result, isA<Success<PatientProfile>>());
    expect(repository.lastToken, 'tok-789');
  });

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.patient, token: 'tok-789');
    repository.result = const ApiError(NetworkFailure('لا يوجد اتصال بالإنترنت'));

    final result = await useCase();

    expect(result, isA<ApiError<PatientProfile>>());
  });
}
