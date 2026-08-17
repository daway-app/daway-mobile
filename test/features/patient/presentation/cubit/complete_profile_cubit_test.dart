import 'dart:io';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/patient_profile.dart';
import 'package:daway_app/features/patient/domain/entities/picked_location.dart';
import 'package:daway_app/features/patient/domain/repositories/avatar_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_profile_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/update_patient_profile_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/upload_avatar_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/complete_profile_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/complete_profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePatientProfileRepository implements PatientProfileRepository {
  PatientProfile? lastProfile;
  ApiResult<void> result = const Success(null);

  @override
  Future<ApiResult<PatientProfile>> getProfile({required String token}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PatientProfile profile,
  }) async {
    lastProfile = profile;
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

class _FakeAvatarRepository implements AvatarRepository {
  ApiResult<String> result = const Success('https://example.com/avatar.jpg');

  @override
  Future<ApiResult<String>> uploadAvatar(File imageFile) async => result;
}

void main() {
  late _FakePatientProfileRepository profileRepository;
  late _FakeAvatarRepository avatarRepository;
  late CompleteProfileCubit cubit;

  setUp(() {
    profileRepository = _FakePatientProfileRepository();
    avatarRepository = _FakeAvatarRepository();
    cubit = CompleteProfileCubit(
      UpdatePatientProfileUseCase(profileRepository, _FakeSessionRepository()),
      UploadAvatarUseCase(avatarRepository),
      phone: '0599123456',
      defaultAvatarUrl: 'https://res.cloudinary.com/demo/default.jpg',
    );
  });

  tearDown(() => cubit.close());

  test('starts with the phone prefilled and nothing else', () {
    expect(cubit.state, isA<CompleteProfileInitial>());
    expect(cubit.state.formData.phone, '0599123456');
    expect(cubit.state.formData.canSubmit, isFalse);
  });

  test('cannot submit until both name and location are set', () {
    cubit.nameChanged('أحمد محمد');
    expect(cubit.state.formData.canSubmit, isFalse);

    cubit.locationSelected(
      const PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة'),
    );
    expect(cubit.state.formData.canSubmit, isTrue);
  });

  group('avatarSelected', () {
    test('stores the uploaded url on success', () async {
      avatarRepository.result = const Success('https://example.com/uploaded.jpg');

      await cubit.avatarSelected(File('avatar.jpg'));

      expect(cubit.state.formData.avatarUrl, 'https://example.com/uploaded.jpg');
      expect(cubit.state.formData.isUploadingAvatar, isFalse);
      expect(cubit.state.formData.avatarError, isNull);
    });

    test('surfaces an error and leaves avatarUrl unset on failure', () async {
      avatarRepository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

      await cubit.avatarSelected(File('avatar.jpg'));

      expect(cubit.state.formData.avatarUrl, isNull);
      expect(cubit.state.formData.avatarError, 'تعذر الاتصال بالخادم');
    });
  });

  group('submit', () {
    test('does nothing when the form is incomplete', () async {
      await cubit.submit();

      expect(cubit.state, isA<CompleteProfileInitial>());
      expect(profileRepository.lastProfile, isNull);
    });

    test('falls back to the default avatar when none was picked', () async {
      cubit.nameChanged('أحمد محمد');
      cubit.locationSelected(
        const PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة'),
      );

      await cubit.submit();

      expect(cubit.state, isA<CompleteProfileSuccess>());
      expect(
        profileRepository.lastProfile?.avatarUrl,
        'https://res.cloudinary.com/demo/default.jpg',
      );
    });

    test('emits failure with the repository message on error', () async {
      profileRepository.result =
          const ApiError(ApiFailure(message: 'فشل الحفظ', code: 'VALIDATION_ERROR'));
      cubit.nameChanged('أحمد محمد');
      cubit.locationSelected(
        const PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة'),
      );

      await cubit.submit();

      expect(cubit.state, isA<CompleteProfileFailure>());
      expect((cubit.state as CompleteProfileFailure).message, 'فشل الحفظ');
    });
  });
}
