import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_ratings_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/submit_pharmacy_rating_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/rate_experience_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePatientRatingsRepository implements PatientRatingsRepository {
  ApiResult<void> result = const Success(null);
  int? lastStars;
  String? lastComment;
  int callCount = 0;

  @override
  Future<ApiResult<void>> submitPharmacyRating({
    required String token,
    required int pharmacyId,
    required int stars,
    String? comment,
  }) async {
    callCount++;
    lastStars = stars;
    lastComment = comment;
    return result;
  }
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession =
      const UserSession(accountType: AccountType.patient, token: 'tok-1');

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
  late _FakePatientRatingsRepository repository;

  RateExperienceCubit buildCubit() {
    return RateExperienceCubit(
      11,
      SubmitPharmacyRatingUseCase(repository, _FakeSessionRepository()),
    );
  }

  setUp(() {
    repository = _FakePatientRatingsRepository();
  });

  test('submitting with nothing rated shows a validation error, no request sent', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await cubit.submit();

    expect(cubit.state.errorMessage, isNotNull);
    expect(repository.lastStars, isNull);
    expect(cubit.state.submitted, isFalse);
  });

  test('rating only the app (no pharmacy stars) submits nothing to the backend', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    cubit.appRatingChanged(4);
    await cubit.submit();

    expect(repository.lastStars, isNull);
    expect(cubit.state.submitted, isTrue);
  });

  test('rating the pharmacy sends its stars and trimmed notes', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    cubit.pharmacyRatingChanged(5);
    cubit.notesChanged('  ممتازة  ');
    await cubit.submit();

    expect(repository.lastStars, 5);
    expect(repository.lastComment, 'ممتازة');
    expect(cubit.state.submitted, isTrue);
  });

  test('empty notes are sent as no comment, not an empty string', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    cubit.pharmacyRatingChanged(3);
    await cubit.submit();

    expect(repository.lastComment, isNull);
  });

  test('a submission failure surfaces the message and does not mark submitted', () async {
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    cubit.pharmacyRatingChanged(2);
    await cubit.submit();

    expect(cubit.state.errorMessage, 'تعذر الاتصال بالخادم');
    expect(cubit.state.submitted, isFalse);
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('a second submit() call while one is already in flight is ignored', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    cubit.pharmacyRatingChanged(5);

    // Fired without awaiting the first — simulates a fast double-tap landing
    // before the button's isLoading-driven disable takes effect.
    final first = cubit.submit();
    final second = cubit.submit();
    await Future.wait([first, second]);

    expect(repository.callCount, 1);
  });

  test('changing a rating clears a previous validation error', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.submit();
    expect(cubit.state.errorMessage, isNotNull);

    cubit.pharmacyRatingChanged(4);

    expect(cubit.state.errorMessage, isNull);
  });
}
