import 'dart:async';
import 'dart:io';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/patient_profile.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/features/patient/domain/repositories/avatar_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_profile_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_profile_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/update_patient_profile_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/upload_avatar_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/patient_profile_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/patient_profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _savedProfile = PatientProfile(
  name: 'أحمد محمد',
  phone: '0599123456',
  latitude: 31.5017,
  longitude: 34.4668,
  address: 'غزة - الرمال',
);

class _FakePatientProfileRepository implements PatientProfileRepository {
  ApiResult<PatientProfile> getResult = const Success(_savedProfile);
  ApiResult<void> updateResult = const Success(null);
  PatientProfile? lastUpdatedProfile;

  /// When set, updateProfile() waits for this to complete instead of
  /// resolving immediately — lets a test pause mid-save to exercise races.
  Completer<void>? updateGate;

  @override
  Future<ApiResult<PatientProfile>> getProfile({required String token}) async => getResult;

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PatientProfile profile,
  }) async {
    lastUpdatedProfile = profile;
    if (updateGate != null) await updateGate!.future;
    return updateResult;
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

class _FakeAvatarRepository implements AvatarRepository {
  ApiResult<String> result = const Success('https://example.com/avatar.jpg');

  /// When set, uploadAvatar() waits for this to complete instead of
  /// resolving immediately — lets a test pause mid-upload to exercise races.
  Completer<void>? uploadGate;

  @override
  Future<ApiResult<String>> uploadAvatar(File imageFile) async {
    if (uploadGate != null) await uploadGate!.future;
    return result;
  }
}

void main() {
  late _FakePatientProfileRepository profileRepository;
  late _FakeAvatarRepository avatarRepository;
  late PatientProfileCubit cubit;

  setUp(() async {
    profileRepository = _FakePatientProfileRepository();
    avatarRepository = _FakeAvatarRepository();
    final sessionRepository = _FakeSessionRepository();
    cubit = PatientProfileCubit(
      GetPatientProfileUseCase(profileRepository, sessionRepository),
      UpdatePatientProfileUseCase(profileRepository, sessionRepository),
      UploadAvatarUseCase(avatarRepository),
    );
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('loads the profile in read-only mode', () {
    final state = cubit.state as PatientProfileLoaded;
    expect(state.name, 'أحمد محمد');
    expect(state.isEditing, isFalse);
    expect(state.hasLocation, isTrue);
    expect(state.isIncomplete, isFalse);
  });

  test('surfaces a load failure', () async {
    profileRepository.getResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await cubit.load();

    expect(cubit.state, isA<PatientProfileLoadFailure>());
  });

  test('a profile with no location yet is flagged incomplete', () async {
    profileRepository.getResult = const Success(
      PatientProfile(name: 'New User', phone: '0599123456'),
    );

    await cubit.load();

    expect((cubit.state as PatientProfileLoaded).isIncomplete, isTrue);
  });

  test('toggleEdit enters edit mode, then discards edits on cancel', () {
    cubit.toggleEdit();
    expect((cubit.state as PatientProfileLoaded).isEditing, isTrue);

    cubit.nameChanged('اسم مختلف');
    expect((cubit.state as PatientProfileLoaded).name, 'اسم مختلف');

    cubit.toggleEdit();
    final state = cubit.state as PatientProfileLoaded;
    expect(state.isEditing, isFalse);
    expect(state.name, 'أحمد محمد');
  });

  test('locationSelected updates coordinates and address while editing', () {
    cubit.toggleEdit();
    cubit.locationSelected(
      const PickedLocation(latitude: 31.9, longitude: 35.2, address: 'رام الله'),
    );

    final state = cubit.state as PatientProfileLoaded;
    expect(state.latitude, 31.9);
    expect(state.address, 'رام الله');
  });

  test('canSave requires a location, matching the onboarding flow', () async {
    profileRepository.getResult = const Success(
      PatientProfile(name: 'New User', phone: '0599123456'),
    );
    await cubit.load();

    cubit.toggleEdit();
    cubit.nameChanged('اسم جديد');
    expect((cubit.state as PatientProfileLoaded).canSave, isFalse);

    cubit.locationSelected(
      const PickedLocation(latitude: 31.9, longitude: 35.2, address: 'رام الله'),
    );
    expect((cubit.state as PatientProfileLoaded).canSave, isTrue);
  });

  test('a save error is cleared as soon as the user edits again', () async {
    cubit.toggleEdit();
    cubit.nameChanged('اسم جديد');
    profileRepository.updateResult =
        const ApiError(ApiFailure(message: 'فشل الحفظ', code: 'VALIDATION_ERROR'));
    await cubit.save();
    expect((cubit.state as PatientProfileLoaded).saveError, 'فشل الحفظ');

    cubit.nameChanged('محاولة تانية');

    expect((cubit.state as PatientProfileLoaded).saveError, isNull);
  });

  test('cancelling while a save is in flight is not undone when it resolves', () async {
    final gate = Completer<void>();
    profileRepository.updateGate = gate;
    cubit.toggleEdit();
    cubit.nameChanged('اسم جديد');

    final saveFuture = cubit.save();
    cubit.toggleEdit(); // cancel before the save resolves
    gate.complete();
    await saveFuture;

    final state = cubit.state as PatientProfileLoaded;
    expect(state.isEditing, isFalse);
    expect(state.name, 'أحمد محمد');
  });

  test('cancelling while an avatar upload is in flight is not undone when it resolves', () async {
    final gate = Completer<void>();
    avatarRepository.uploadGate = gate;
    cubit.toggleEdit();

    final uploadFuture = cubit.avatarSelected(File('avatar.jpg'));
    cubit.toggleEdit(); // cancel before the upload resolves
    gate.complete();
    await uploadFuture;

    final state = cubit.state as PatientProfileLoaded;
    expect(state.isEditing, isFalse);
    expect(state.avatarUrl, isNull);
  });

  group('save', () {
    test('does nothing when the name is blank', () async {
      cubit.toggleEdit();
      cubit.nameChanged('   ');

      await cubit.save();

      expect(profileRepository.lastUpdatedProfile, isNull);
    });

    test('sends the edited fields and exits edit mode on success', () async {
      cubit.toggleEdit();
      cubit.nameChanged('اسم جديد');

      await cubit.save();

      final state = cubit.state as PatientProfileLoaded;
      expect(state.isEditing, isFalse);
      expect(state.name, 'اسم جديد');
      expect(profileRepository.lastUpdatedProfile?.name, 'اسم جديد');
    });

    test('surfaces a failure and stays in edit mode', () async {
      cubit.toggleEdit();
      cubit.nameChanged('اسم جديد');
      profileRepository.updateResult =
          const ApiError(ApiFailure(message: 'فشل الحفظ', code: 'VALIDATION_ERROR'));

      await cubit.save();

      final state = cubit.state as PatientProfileLoaded;
      expect(state.isEditing, isTrue);
      expect(state.saveError, 'فشل الحفظ');
    });
  });
}
