import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:daway_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/patient_auth_cubit.dart';
import 'package:daway_app/features/auth/presentation/cubit/patient_auth_state.dart';
import 'package:daway_app/features/patient/domain/repositories/location_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_current_location_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  String? lastSendOtpPhone;
  String? lastVerifyPhone;
  String? lastVerifyOtp;
  String? lastVerifyName;
  String? lastVerifyBirthDate;
  double? lastVerifyLatitude;
  double? lastVerifyLongitude;
  ApiResult<String?> sendOtpResult = const Success(null);
  ApiResult<PatientAuthResult> verifyResult =
      const Success(PatientAuthResult(token: 'fake-token', isNewAccount: false));

  @override
  Future<ApiResult<String?>> sendOtp({required String phone}) async {
    lastSendOtpPhone = phone;
    return sendOtpResult;
  }

  @override
  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
    String? name,
    String? birthDate,
    double? latitude,
    double? longitude,
    bool? notificationsEnabled,
  }) async {
    lastVerifyPhone = phone;
    lastVerifyOtp = otp;
    lastVerifyName = name;
    lastVerifyBirthDate = birthDate;
    lastVerifyLatitude = latitude;
    lastVerifyLongitude = longitude;
    return verifyResult;
  }

  @override
  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) async => const Success(PharmacyAuthResult(token: 'fake-token'));

  @override
  Future<ApiResult<void>> logout({required String token}) async => const Success(null);
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

class _FakeLocationRepository implements LocationRepository {
  ApiResult<PickedLocation> currentLocationResult =
      const Success(PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة'));

  @override
  Future<ApiResult<PickedLocation>> getCurrentLocation() async => currentLocationResult;

  @override
  Future<ApiResult<String>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async => const Success('غزة');

  @override
  Future<ApiResult<PickedLocation>> searchAddress(String query) async =>
      const Success(PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة'));
}

void main() {
  late _FakeAuthRepository repository;
  late _FakeSessionRepository sessionRepository;
  late _FakeLocationRepository locationRepository;
  late PatientAuthCubit cubit;

  setUp(() {
    repository = _FakeAuthRepository();
    sessionRepository = _FakeSessionRepository();
    locationRepository = _FakeLocationRepository();
    cubit = PatientAuthCubit(
      SendOtpUseCase(repository),
      VerifyOtpUseCase(repository),
      SaveSessionUseCase(sessionRepository),
      GetCurrentLocationUseCase(locationRepository),
    );
  });

  tearDown(() => cubit.close());

  group('sendOtp', () {
    test('rejects an invalid phone', () async {
      cubit.phoneChanged('123');

      await cubit.sendOtp();

      expect(cubit.state.otpSent, isFalse);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('sends the 10-digit local phone as-is on success', () async {
      cubit.phoneChanged('0599123456');

      await cubit.sendOtp();

      expect(cubit.state.otpSent, isTrue);
      expect(cubit.state.isSendingOtp, isFalse);
      expect(repository.lastSendOtpPhone, '0599123456');
    });

    test('surfaces the failure message on error', () async {
      repository.sendOtpResult =
          const ApiError(ApiFailure(message: 'فشل الإرسال', code: 'VALIDATION_ERROR'));
      cubit.phoneChanged('0599123456');

      await cubit.sendOtp();

      expect(cubit.state.otpSent, isFalse);
      expect(cubit.state.errorMessage, 'فشل الإرسال');
    });

    test('succeeds whether or not the backend echoes the OTP back', () async {
      repository.sendOtpResult = const Success('519979');
      cubit.phoneChanged('0599123456');

      await cubit.sendOtp();

      expect(cubit.state.otpSent, isTrue);
    });
  });

  group('backToPhoneStep', () {
    test('clears otpSent and any error', () async {
      cubit.phoneChanged('0599123456');
      await cubit.sendOtp();

      cubit.backToPhoneStep();

      expect(cubit.state.otpSent, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });
  });

  group('verifyOtp (plain login, no name/birth date set)', () {
    test('rejects an otp that is not 6 digits', () async {
      await cubit.verifyOtp('12345');

      expect(cubit.state.destination, isNull);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('routes to home on success', () async {
      repository.verifyResult =
          const Success(PatientAuthResult(token: 'tok', isNewAccount: false));
      cubit.phoneChanged('0599123456');

      await cubit.verifyOtp('123456');

      expect(cubit.state.destination, AuthDestination.home);
      expect(repository.lastVerifyOtp, '123456');
      expect(repository.lastVerifyName, isNull);
    });

    test('persists the session on success', () async {
      repository.verifyResult =
          const Success(PatientAuthResult(token: 'tok', isNewAccount: false));
      cubit.phoneChanged('0599123456');

      await cubit.verifyOtp('123456');

      expect(sessionRepository.savedSession?.accountType, AccountType.patient);
      expect(sessionRepository.savedSession?.token, 'tok');
    });

    test('surfaces the failure message on error', () async {
      repository.verifyResult =
          const ApiError(ApiFailure(message: 'رمز التحقق غير صحيح', code: 'OTP_INVALID'));
      cubit.phoneChanged('0599123456');

      await cubit.verifyOtp('123456');

      expect(cubit.state.destination, isNull);
      expect(cubit.state.errorMessage, 'رمز التحقق غير صحيح');
    });

    test('a registration_required rejection surfaces a sign-up prompt instead of asking for location',
        () async {
      repository.verifyResult = const ApiError(
        ApiFailure(message: 'يرجى إدخال بيانات التسجيل', registrationRequired: true),
      );
      cubit.phoneChanged('0599123456');

      await cubit.verifyOtp('123456');

      expect(cubit.state.needsLocation, isFalse);
      expect(cubit.state.errorMessage, 'لا يوجد حساب بهذا الرقم، يرجى إنشاء حساب جديد');
    });
  });

  group('verifyOtp (sign-up, name/birth date set)', () {
    setUp(() {
      cubit.phoneChanged('0599123456');
      cubit.nameChanged('عبدالرحمن');
      cubit.birthDateChanged('2005-08-15');
    });

    test('sends the registration payload alongside phone+otp', () async {
      repository.verifyResult =
          const Success(PatientAuthResult(token: 'tok', isNewAccount: true));

      await cubit.verifyOtp('123456');

      expect(repository.lastVerifyName, 'عبدالرحمن');
      expect(repository.lastVerifyBirthDate, '2005-08-15');
    });

    test('routes to notifications (not home) once verified', () async {
      repository.verifyResult =
          const Success(PatientAuthResult(token: 'tok', isNewAccount: true));

      await cubit.verifyOtp('123456');

      expect(cubit.state.destination, AuthDestination.notifications);
    });

    test('a registration_required rejection asks for location instead of erroring', () async {
      repository.verifyResult = const ApiError(
        ApiFailure(message: 'يرجى إدخال بيانات التسجيل', registrationRequired: true),
      );

      await cubit.verifyOtp('123456');

      expect(cubit.state.needsLocation, isTrue);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.destination, isNull);
    });

    test('useCurrentLocation resends the same OTP with coordinates and succeeds', () async {
      repository.verifyResult = const ApiError(
        ApiFailure(message: 'يرجى إدخال بيانات التسجيل', registrationRequired: true),
      );
      await cubit.verifyOtp('123456');
      expect(cubit.state.needsLocation, isTrue);

      repository.verifyResult =
          const Success(PatientAuthResult(token: 'tok', isNewAccount: true));
      await cubit.useCurrentLocation();

      expect(repository.lastVerifyOtp, '123456');
      expect(repository.lastVerifyLatitude, 31.5);
      expect(repository.lastVerifyLongitude, 34.46);
      expect(cubit.state.destination, AuthDestination.notifications);
    });

    test(
        'a registration_required rejection asks for location again even when a stale one is already set',
        () async {
      repository.verifyResult = const ApiError(
        ApiFailure(message: 'يرجى إدخال بيانات التسجيل', registrationRequired: true),
      );
      await cubit.verifyOtp('123456');
      expect(cubit.state.needsLocation, isTrue);

      repository.verifyResult =
          const Success(PatientAuthResult(token: 'tok', isNewAccount: true));
      await cubit.useCurrentLocation();
      expect(cubit.state.latitude, isNotNull);

      // The backend rejects again with registrationRequired despite already
      // having a latitude on file (e.g. it was stale/invalid) — the cubit
      // must send the user back to the location step to retry, not dead-end
      // into a generic error.
      repository.verifyResult = const ApiError(
        ApiFailure(message: 'يرجى إدخال بيانات التسجيل', registrationRequired: true),
      );
      await cubit.verifyOtp('123456');

      expect(cubit.state.needsLocation, isTrue);
      expect(cubit.state.errorMessage, isNull);
    });

    test('a location failure surfaces locationError without losing the otp', () async {
      locationRepository.currentLocationResult =
          const ApiError(PermissionFailure('يرجى السماح بالوصول لموقعك'));

      await cubit.useCurrentLocation();

      expect(cubit.state.locationError, 'يرجى السماح بالوصول لموقعك');
      expect(cubit.state.destination, isNull);
    });
  });
}
