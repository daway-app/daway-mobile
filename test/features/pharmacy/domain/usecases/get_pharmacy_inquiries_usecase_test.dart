import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/inquiry.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_inquiries_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_inquiries_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

const _overview = InquiriesOverview(
  inquiries: [],
  newCount: 3,
  answeredCount: 18,
  closedCount: 42,
);

class _FakePharmacyInquiriesRepository implements PharmacyInquiriesRepository {
  String? lastToken;
  ApiResult<InquiriesOverview> getResult = const Success(_overview);

  @override
  Future<ApiResult<InquiriesOverview>> getInquiries({
    required String token,
  }) async {
    lastToken = token;
    return getResult;
  }

  @override
  Future<ApiResult<void>> updateInquiryStatus({
    required String token,
    required int inquiryId,
    required InquiryStatus status,
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
  late _FakePharmacyInquiriesRepository repository;
  late _FakeSessionRepository sessionRepository;
  late GetPharmacyInquiriesUseCase useCase;

  setUp(() {
    repository = _FakePharmacyInquiriesRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = GetPharmacyInquiriesUseCase(repository, sessionRepository);
  });

  test(
    'fails without hitting the repository when there is no saved session',
    () async {
      final result = await useCase();

      expect(result, isA<ApiError<InquiriesOverview>>());
      expect(repository.lastToken, isNull);
    },
  );

  test('fetches inquiries using the saved session token', () async {
    sessionRepository.savedSession = const UserSession(
      accountType: AccountType.pharmacy,
      token: 'tok-1',
    );

    final result = await useCase();

    expect(result, isA<Success<InquiriesOverview>>());
    expect(repository.lastToken, 'tok-1');
  });

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession = const UserSession(
      accountType: AccountType.pharmacy,
      token: 'tok-1',
    );
    repository.getResult = const ApiError(
      NetworkFailure('لا يوجد اتصال بالإنترنت'),
    );

    final result = await useCase();

    expect(result, isA<ApiError<InquiriesOverview>>());
  });
}
