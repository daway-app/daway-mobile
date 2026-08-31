import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/rating.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_ratings_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_ratings_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_ratings_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_ratings_state.dart';
import 'package:flutter_test/flutter_test.dart';

final _rating = Rating(
  id: 1,
  stars: 5,
  comment: 'ممتاز',
  createdAt: DateTime(2026, 8, 22),
  patientName: 'أحمد',
);

class _FakePharmacyRatingsRepository implements PharmacyRatingsRepository {
  ApiResult<RatingsOverview> getResult = Success(
    RatingsOverview(
      ratings: [_rating],
      totalCount: 1,
      averageRating: 5,
      starCounts: const {5: 1, 4: 0, 3: 0, 2: 0, 1: 0},
    ),
  );

  @override
  Future<ApiResult<RatingsOverview>> getRatings({required String token}) async =>
      getResult;
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession = const UserSession(
    accountType: AccountType.pharmacy,
    token: 'tok-1',
  );

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
  late _FakePharmacyRatingsRepository repository;
  late PharmacyRatingsCubit cubit;

  setUp(() async {
    repository = _FakePharmacyRatingsRepository();
    final sessionRepository = _FakeSessionRepository();
    cubit = PharmacyRatingsCubit(
      GetPharmacyRatingsUseCase(repository, sessionRepository),
    );
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('loads the ratings overview', () {
    final state = cubit.state as PharmacyRatingsLoaded;
    expect(state.ratings, [_rating]);
    expect(state.totalCount, 1);
    expect(state.averageRating, 5);
    expect(state.starCounts, {5: 1, 4: 0, 3: 0, 2: 0, 1: 0});
  });

  test('surfaces a load failure', () async {
    repository.getResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await cubit.load();

    expect(cubit.state, isA<PharmacyRatingsLoadFailure>());
  });

  test('load can recover from a failure back to loaded', () async {
    // Drives the cubit into a failure state first (already covered by
    // 'surfaces a load failure' above) purely as the precondition for the
    // one behavior this test actually asserts: recovering from it.
    repository.getResult = const ApiError(ApiFailure(message: 'خطأ'));
    await cubit.load();

    repository.getResult = Success(
      RatingsOverview(
        ratings: [_rating],
        totalCount: 1,
        averageRating: 5,
        starCounts: const {5: 1, 4: 0, 3: 0, 2: 0, 1: 0},
      ),
    );
    await cubit.load();

    expect(cubit.state, isA<PharmacyRatingsLoaded>());
  });
}
