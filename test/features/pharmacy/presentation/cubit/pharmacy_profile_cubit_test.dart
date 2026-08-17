import 'dart:async';
import 'dart:io';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/avatar_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/upload_avatar_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/entities/pharmacy_profile.dart';
import 'package:daway_app/features/pharmacy/domain/entities/working_hours_entry.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_profile_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_profile_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/update_pharmacy_profile_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_profile_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _savedProfile = PharmacyProfile(
  pharmacyId: 'PH-1234',
  name: 'صيدلية الأمل',
  phone: '+970591234567',
  latitude: 31.5016,
  longitude: 34.4668,
  address: 'غزة - شارع الوحدة',
  workingHours: [
    WorkingHoursEntry(day: WeekDay.sat, open: '09:00', close: '22:00'),
    WorkingHoursEntry(day: WeekDay.sun, open: '09:00', close: '22:00'),
    WorkingHoursEntry(day: WeekDay.mon, open: '09:00', close: '22:00'),
    WorkingHoursEntry(day: WeekDay.tue),
    WorkingHoursEntry(day: WeekDay.wed),
    WorkingHoursEntry(day: WeekDay.thu),
    WorkingHoursEntry(day: WeekDay.fri),
  ],
);

class _FakePharmacyProfileRepository implements PharmacyProfileRepository {
  ApiResult<PharmacyProfile> getResult = const Success(_savedProfile);
  ApiResult<void> updateResult = const Success(null);
  PharmacyProfile? lastUpdatedProfile;

  /// When set, updateProfile() waits for this to complete instead of
  /// resolving immediately — lets a test pause mid-save to exercise races.
  Completer<void>? updateGate;

  @override
  Future<ApiResult<PharmacyProfile>> getProfile({required String token}) async => getResult;

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PharmacyProfile profile,
  }) async {
    lastUpdatedProfile = profile;
    if (updateGate != null) await updateGate!.future;
    return updateResult;
  }
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession =
      const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');

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
  ApiResult<String> result = const Success('https://example.com/logo.jpg');

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
  late _FakePharmacyProfileRepository profileRepository;
  late _FakeAvatarRepository logoRepository;
  late PharmacyProfileCubit cubit;

  setUp(() async {
    profileRepository = _FakePharmacyProfileRepository();
    logoRepository = _FakeAvatarRepository();
    final sessionRepository = _FakeSessionRepository();
    cubit = PharmacyProfileCubit(
      GetPharmacyProfileUseCase(profileRepository, sessionRepository),
      UpdatePharmacyProfileUseCase(profileRepository, sessionRepository),
      UploadAvatarUseCase(logoRepository),
    );
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('loads the profile in read-only mode', () {
    final state = cubit.state as PharmacyProfileLoaded;
    expect(state.name, 'صيدلية الأمل');
    expect(state.isEditing, isFalse);
    expect(state.hasLocation, isTrue);
    expect(state.isIncomplete, isFalse);
    expect(state.workingHours.length, 7);
  });

  test('surfaces a load failure', () async {
    profileRepository.getResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await cubit.load();

    expect(cubit.state, isA<PharmacyProfileLoadFailure>());
  });

  test('a profile with no location yet is flagged incomplete', () async {
    profileRepository.getResult = const Success(
      PharmacyProfile(pharmacyId: 'PH-1', name: 'صيدلية جديدة', phone: '+970591234567'),
    );

    await cubit.load();

    expect((cubit.state as PharmacyProfileLoaded).isIncomplete, isTrue);
  });

  test('toggleEdit enters edit mode, then discards edits on cancel', () {
    cubit.toggleEdit();
    expect((cubit.state as PharmacyProfileLoaded).isEditing, isTrue);

    cubit.nameChanged('اسم مختلف');
    expect((cubit.state as PharmacyProfileLoaded).name, 'اسم مختلف');

    cubit.toggleEdit();
    final state = cubit.state as PharmacyProfileLoaded;
    expect(state.isEditing, isFalse);
    expect(state.name, 'صيدلية الأمل');
  });

  test('workingHoursChanged updates only the targeted day', () {
    cubit.toggleEdit();
    cubit.workingHoursChanged(WeekDay.tue, open: '10:00', close: '20:00');

    final state = cubit.state as PharmacyProfileLoaded;
    final tue = state.workingHours.firstWhere((e) => e.day == WeekDay.tue);
    expect(tue.open, '10:00');
    expect(tue.close, '20:00');
    final sat = state.workingHours.firstWhere((e) => e.day == WeekDay.sat);
    expect(sat.open, '09:00');
  });

  test('canSave requires a location', () async {
    profileRepository.getResult = const Success(
      PharmacyProfile(pharmacyId: 'PH-1', name: 'صيدلية جديدة', phone: '+970591234567'),
    );
    await cubit.load();

    cubit.toggleEdit();
    cubit.nameChanged('اسم جديد');
    expect((cubit.state as PharmacyProfileLoaded).canSave, isFalse);

    cubit.locationSelected(
      const PickedLocation(latitude: 31.9, longitude: 35.2, address: 'رام الله'),
    );
    expect((cubit.state as PharmacyProfileLoaded).canSave, isTrue);
  });

  test('a save error is cleared as soon as the user edits again', () async {
    cubit.toggleEdit();
    cubit.nameChanged('اسم جديد');
    profileRepository.updateResult =
        const ApiError(ApiFailure(message: 'فشل الحفظ', code: 'VALIDATION_ERROR'));
    await cubit.save();
    expect((cubit.state as PharmacyProfileLoaded).saveError, 'فشل الحفظ');

    cubit.nameChanged('محاولة تانية');

    expect((cubit.state as PharmacyProfileLoaded).saveError, isNull);
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

    final state = cubit.state as PharmacyProfileLoaded;
    expect(state.isEditing, isFalse);
    expect(state.name, 'صيدلية الأمل');
  });

  test('cancelling while a logo upload is in flight is not undone when it resolves', () async {
    final gate = Completer<void>();
    logoRepository.uploadGate = gate;
    cubit.toggleEdit();

    final uploadFuture = cubit.logoSelected(File('logo.jpg'));
    cubit.toggleEdit(); // cancel before the upload resolves
    gate.complete();
    await uploadFuture;

    final state = cubit.state as PharmacyProfileLoaded;
    expect(state.isEditing, isFalse);
    expect(state.logoUrl, isNull);
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

      final state = cubit.state as PharmacyProfileLoaded;
      expect(state.isEditing, isFalse);
      expect(state.name, 'اسم جديد');
      expect(profileRepository.lastUpdatedProfile?.name, 'اسم جديد');
      expect(profileRepository.lastUpdatedProfile?.pharmacyId, 'PH-1234');
    });

    test('surfaces a failure and stays in edit mode', () async {
      cubit.toggleEdit();
      cubit.nameChanged('اسم جديد');
      profileRepository.updateResult =
          const ApiError(ApiFailure(message: 'فشل الحفظ', code: 'VALIDATION_ERROR'));

      await cubit.save();

      final state = cubit.state as PharmacyProfileLoaded;
      expect(state.isEditing, isTrue);
      expect(state.saveError, 'فشل الحفظ');
    });
  });
}
