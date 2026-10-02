import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/data/models/patient_health_profile_model.dart';
import 'package:daway_app/features/patient/domain/entities/patient_health_profile.dart';
import 'package:daway_app/features/patient/domain/repositories/health_profile_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/health_profile_usecases.dart';
import 'package:daway_app/features/patient/presentation/cubit/health_profile_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/health_profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements HealthProfileRepository {
  ApiResult<PatientHealthProfile> getResult = const Success(
    PatientHealthProfile(
      allergies: ['Penicillin'],
      chronicDiseases: ['Diabetes'],
      bloodType: 'A+',
      notes: 'حساسية من الدخان',
    ),
  );
  ApiResult<PatientHealthProfile>? updateResult;
  PatientHealthProfile? lastSaved;

  @override
  Future<ApiResult<PatientHealthProfile>> getHealthProfile({required String token}) async =>
      getResult;

  @override
  Future<ApiResult<PatientHealthProfile>> updateHealthProfile({
    required String token,
    required PatientHealthProfile profile,
  }) async {
    lastSaved = profile;
    return updateResult ?? Success(profile);
  }
}

class _FakeSession implements SessionRepository {
  @override
  Future<UserSession?> getSession() async =>
      const UserSession(accountType: AccountType.patient, token: 'tok');

  @override
  Future<void> saveSession(UserSession session) async {}

  @override
  Future<void> clearSession() async {}
}

void main() {
  late _FakeRepository repository;

  Future<HealthProfileCubit> loadedCubit() async {
    final cubit = HealthProfileCubit(
      GetHealthProfileUseCase(repository, _FakeSession()),
      UpdateHealthProfileUseCase(repository, _FakeSession()),
    );
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  setUp(() => repository = _FakeRepository());

  test('loads the profile the server has', () async {
    final cubit = await loadedCubit();

    final state = cubit.state as HealthProfileLoaded;
    expect(state.allergies, ['Penicillin']);
    expect(state.chronicDiseases, ['Diabetes']);
    expect(state.bloodType, 'A+');
    expect(state.notes, 'حساسية من الدخان');
  });

  test('a failed load surfaces its message', () async {
    repository.getResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = await loadedCubit();

    expect((cubit.state as HealthProfileLoadFailure).message, 'تعذر الاتصال بالخادم');
  });

  test('adding trims, and ignores blanks and duplicates', () async {
    final cubit = await loadedCubit();

    cubit.addAllergy('  Aspirin ');
    cubit.addAllergy('Aspirin');
    cubit.addAllergy('   ');

    expect((cubit.state as HealthProfileLoaded).allergies, ['Penicillin', 'Aspirin']);
  });

  test('removing drops just that entry', () async {
    final cubit = await loadedCubit();

    cubit.removeChronicDisease('Diabetes');

    expect((cubit.state as HealthProfileLoaded).chronicDiseases, isEmpty);
  });

  test('tapping the selected blood type again clears it', () async {
    final cubit = await loadedCubit();

    cubit.selectBloodType('O-');
    expect((cubit.state as HealthProfileLoaded).bloodType, 'O-');
    cubit.selectBloodType('O-');
    expect((cubit.state as HealthProfileLoaded).bloodType, isNull);
  });

  test('save sends the edited profile with trimmed notes and returns null', () async {
    final cubit = await loadedCubit();
    cubit.addAllergy('Aspirin');

    final error = await cubit.save('  ملاحظة  ');

    expect(error, isNull);
    expect(repository.lastSaved!.allergies, ['Penicillin', 'Aspirin']);
    expect(repository.lastSaved!.notes, 'ملاحظة');
    expect((cubit.state as HealthProfileLoaded).isSaving, isFalse);
  });

  test('a failed save returns the message and keeps the edits', () async {
    repository.updateResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = await loadedCubit();
    cubit.addAllergy('Aspirin');

    final error = await cubit.save('');

    expect(error, 'تعذر الاتصال بالخادم');
    final state = cubit.state as HealthProfileLoaded;
    expect(state.isSaving, isFalse);
    expect(state.allergies, contains('Aspirin'));
  });

  test('the model reads the API shape and tolerates a null blood type', () {
    final model = PatientHealthProfileModel.fromJson({
      'user_id': 4,
      'allergies': ['Penicillin', 'Aspirin'],
      'chronic_diseases': ['Diabetes'],
      'blood_type': null,
      'notes': null,
    });

    expect(model.allergies, ['Penicillin', 'Aspirin']);
    expect(model.bloodType, isNull);
    expect(model.notes, '');
  });
}
