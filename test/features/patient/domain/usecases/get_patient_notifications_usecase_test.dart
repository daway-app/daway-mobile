import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/patient_notification.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_notifications_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_notifications_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements PatientNotificationsRepository {
  ApiResult<List<PatientNotification>> result = const Success([]);
  String? lastToken;

  @override
  Future<ApiResult<List<PatientNotification>>> getNotifications({required String token}) async {
    lastToken = token;
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
  test('passes the session token through to the repository', () async {
    final repository = _FakeRepository();
    repository.result = Success([
      PatientNotification(
        id: 1,
        type: PatientNotificationType.system,
        message: 'x',
        isRead: false,
        createdAt: DateTime(2026, 9, 24),
      ),
    ]);
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = GetPatientNotificationsUseCase(repository, sessionRepository);

    final result = await useCase();

    expect(repository.lastToken, 'tok-1');
    expect(result, isA<Success<List<PatientNotification>>>());
    expect((result as Success).data, hasLength(1));
  });

  test('returns a session failure without calling the repository when logged out', () async {
    final repository = _FakeRepository();
    final useCase = GetPatientNotificationsUseCase(repository, _FakeSessionRepository());

    final result = await useCase();

    expect(result, isA<ApiError<List<PatientNotification>>>());
    expect(repository.lastToken, isNull);
  });

  test('surfaces a repository failure unchanged', () async {
    final repository = _FakeRepository();
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final sessionRepository = _FakeSessionRepository()
      ..savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');
    final useCase = GetPatientNotificationsUseCase(repository, sessionRepository);

    final result = await useCase();

    expect(result, isA<ApiError<List<PatientNotification>>>());
  });
}
