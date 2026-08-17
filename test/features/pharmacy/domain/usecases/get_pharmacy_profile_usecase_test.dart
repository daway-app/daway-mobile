import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_profile.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_profile_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePharmacyProfileRepository implements PharmacyProfileRepository {
  String? lastToken;
  ApiResult<PharmacyProfile> result = const Success(
    PharmacyProfile(pharmacyId: 'PH-1234', name: 'صيدلية الأمل', phone: '+970591234567'),
  );

  @override
  Future<ApiResult<PharmacyProfile>> getProfile({required String token}) async {
    lastToken = token;
    return result;
  }

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PharmacyProfile profile,
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
  late _FakePharmacyProfileRepository repository;
  late _FakeSessionRepository sessionRepository;
  late GetPharmacyProfileUseCase useCase;

  setUp(() {
    repository = _FakePharmacyProfileRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = GetPharmacyProfileUseCase(repository, sessionRepository);
  });

  test('fails without hitting the repository when there is no saved session', () async {
    final result = await useCase();

    expect(result, isA<ApiError<PharmacyProfile>>());
    expect(repository.lastToken, isNull);
  });

  test('fetches the profile using the saved session token', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-789');

    final result = await useCase();

    expect(result, isA<Success<PharmacyProfile>>());
    expect(repository.lastToken, 'tok-789');
  });

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-789');
    repository.result = const ApiError(NetworkFailure('لا يوجد اتصال بالإنترنت'));

    final result = await useCase();

    expect(result, isA<ApiError<PharmacyProfile>>());
  });
}
