import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/inquiry.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_inquiries_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/update_inquiry_status_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePharmacyInquiriesRepository implements PharmacyInquiriesRepository {
  String? lastToken;
  int? lastInquiryId;
  InquiryStatus? lastStatus;
  ApiResult<void> updateResult = const Success(null);

  @override
  Future<ApiResult<InquiriesOverview>> getInquiries({
    required String token,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> updateInquiryStatus({
    required String token,
    required int inquiryId,
    required InquiryStatus status,
  }) async {
    lastToken = token;
    lastInquiryId = inquiryId;
    lastStatus = status;
    return updateResult;
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
  late UpdateInquiryStatusUseCase useCase;

  setUp(() {
    repository = _FakePharmacyInquiriesRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = UpdateInquiryStatusUseCase(repository, sessionRepository);
  });

  test(
    'fails without hitting the repository when there is no saved session',
    () async {
      final result = await useCase(
        inquiryId: 7,
        status: InquiryStatus.answered,
      );

      expect(result, isA<ApiError<void>>());
      expect(repository.lastToken, isNull);
    },
  );

  test('updates status using the saved session token', () async {
    sessionRepository.savedSession = const UserSession(
      accountType: AccountType.pharmacy,
      token: 'tok-1',
    );

    final result = await useCase(inquiryId: 7, status: InquiryStatus.closed);

    expect(result, isA<Success<void>>());
    expect(repository.lastToken, 'tok-1');
    expect(repository.lastInquiryId, 7);
    expect(repository.lastStatus, InquiryStatus.closed);
  });

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession = const UserSession(
      accountType: AccountType.pharmacy,
      token: 'tok-1',
    );
    repository.updateResult = const ApiError(
      ApiFailure(message: 'فشل التحديث'),
    );

    final result = await useCase(inquiryId: 7, status: InquiryStatus.answered);

    expect(result, isA<ApiError<void>>());
  });
}
