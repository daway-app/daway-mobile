import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/patient_notification.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_notifications_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_notifications_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/patient_notifications_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/patient_notifications_state.dart';
import 'package:flutter_test/flutter_test.dart';

final _notifications = [
  PatientNotification(
    id: 1,
    type: PatientNotificationType.system,
    message: 'x',
    isRead: false,
    createdAt: DateTime(2026, 9, 24),
  ),
];

class _FakeRepository implements PatientNotificationsRepository {
  late ApiResult<List<PatientNotification>> result = Success(_notifications);

  @override
  Future<ApiResult<List<PatientNotification>>> getNotifications({required String token}) async =>
      result;
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
  late _FakeRepository repository;

  setUp(() {
    repository = _FakeRepository();
  });

  PatientNotificationsCubit buildCubit() {
    final cubit = PatientNotificationsCubit(
      GetPatientNotificationsUseCase(repository, _FakeSessionRepository()),
    );
    addTearDown(cubit.close);
    return cubit;
  }

  test('loads the notifications on construction', () async {
    final cubit = buildCubit();

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<PatientNotificationsLoaded>());
    expect((cubit.state as PatientNotificationsLoaded).notifications, _notifications);
  });

  test('surfaces a load failure', () async {
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<PatientNotificationsLoadFailure>());
    expect((cubit.state as PatientNotificationsLoadFailure).message, 'تعذر الاتصال بالخادم');
  });

  test('load() can be called again to retry after a failure', () async {
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isA<PatientNotificationsLoadFailure>());

    repository.result = Success(_notifications);
    await cubit.load();

    expect(cubit.state, isA<PatientNotificationsLoaded>());
  });
}
