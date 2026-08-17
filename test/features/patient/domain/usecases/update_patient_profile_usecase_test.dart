import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/patient_profile.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_profile_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/update_patient_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePatientProfileRepository implements PatientProfileRepository {
  String? lastToken;
  PatientProfile? lastProfile;
  ApiResult<void> result = const Success(null);

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PatientProfile profile,
  }) async {
    lastToken = token;
    lastProfile = profile;
    return result;
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
  late UpdatePatientProfileUseCase useCase;

  const profile = PatientProfile(
    name: 'أحمد محمد',
    phone: '0599123456',
    latitude: 31.5017,
    longitude: 34.4668,
    address: 'غزة - الرمال',
  );

  setUp(() {
    repository = _FakePatientProfileRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = UpdatePatientProfileUseCase(repository, sessionRepository);
  });

  test('fails without hitting the repository when there is no saved session', () async {
    final result = await useCase(profile);

    expect(result, isA<ApiError<void>>());
    expect(repository.lastProfile, isNull);
  });

  test('sends the session token and profile to the repository', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.patient, token: 'tok-789');

    final result = await useCase(profile);

    expect(result, isA<Success<void>>());
    expect(repository.lastToken, 'tok-789');
    expect(repository.lastProfile?.name, profile.name);
    expect(repository.lastProfile?.address, profile.address);
  });

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.patient, token: 'tok-789');
    repository.result = const ApiError(NetworkFailure('لا يوجد اتصال بالإنترنت'));

    final result = await useCase(profile);

    expect(result, isA<ApiError<void>>());
  });
}
