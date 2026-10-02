import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_ratings_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/submit_pharmacy_rating_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePatientRatingsRepository implements PatientRatingsRepository {
  ApiResult<void> result = const Success(null);
  String? lastToken;
  int? lastPharmacyId;
  int? lastStars;
  String? lastComment;

  @override
  Future<ApiResult<void>> submitPharmacyRating({
    required String token,
    required int pharmacyId,
    required int stars,
    String? comment,
  }) async {
    lastToken = token;
    lastPharmacyId = pharmacyId;
    lastStars = stars;
    lastComment = comment;
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
  test('passes the session token and fields through to the repository', () async {
    final repository = _FakePatientRatingsRepository();
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = SubmitPharmacyRatingUseCase(repository, sessionRepository);

    final result = await useCase(pharmacyId: 11, stars: 5, comment: 'ممتازة');

    expect(repository.lastToken, 'tok-1');
    expect(repository.lastPharmacyId, 11);
    expect(repository.lastStars, 5);
    expect(repository.lastComment, 'ممتازة');
    expect(result, isA<Success<void>>());
  });

  test('returns a session failure without calling the repository when logged out', () async {
    final repository = _FakePatientRatingsRepository();
    final sessionRepository = _FakeSessionRepository();
    final useCase = SubmitPharmacyRatingUseCase(repository, sessionRepository);

    final result = await useCase(pharmacyId: 11, stars: 5);

    expect(result, isA<ApiError<void>>());
    expect(repository.lastPharmacyId, isNull);
  });

  test('surfaces a repository failure unchanged', () async {
    final repository = _FakePatientRatingsRepository()
      ..result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = SubmitPharmacyRatingUseCase(repository, sessionRepository);

    final result = await useCase(pharmacyId: 11, stars: 5);

    expect(result, isA<ApiError<void>>());
  });
}
