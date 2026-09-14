import 'package:daway_app/core/routing/initial_route_resolver.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSessionRepository implements SessionRepository {
  final UserSession? session;
  final Object? readError;

  _FakeSessionRepository({this.session, this.readError});

  @override
  Future<UserSession?> getSession() async {
    if (readError != null) throw readError!;
    return session;
  }

  @override
  Future<void> saveSession(UserSession session) async {}

  @override
  Future<void> clearSession() async {}
}

InitialRouteResolver _buildResolver({UserSession? session, Object? sessionReadError}) {
  return InitialRouteResolver(
    GetSessionUseCase(
      _FakeSessionRepository(session: session, readError: sessionReadError),
    ),
  );
}

void main() {
  test('resolves to patient home when a patient session exists', () async {
    final route = await _buildResolver(
      session: const UserSession(
        accountType: AccountType.patient,
        token: 'tok',
      ),
    ).resolve();

    expect(route, Routes.patientHomeScreen);
  });

  test('resolves to pharmacy home when a pharmacy session exists', () async {
    final route = await _buildResolver(
      session: const UserSession(
        accountType: AccountType.pharmacy,
        token: 'tok',
      ),
    ).resolve();

    expect(route, Routes.pharmacyHomeScreen);
  });

  test('resolves to account type screen when there is no session', () async {
    final route = await _buildResolver(session: null).resolve();

    expect(route, Routes.accountTypeScreen);
  });

  test(
    'falls back to account type screen instead of crashing startup when session read fails',
    () async {
      final route = await _buildResolver(
        sessionReadError: Exception('storage error'),
      ).resolve();

      expect(route, Routes.accountTypeScreen);
    },
  );
}
