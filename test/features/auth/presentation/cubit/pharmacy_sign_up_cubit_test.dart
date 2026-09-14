import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/usecases/register_pharmacy_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/pharmacy_sign_up_cubit.dart';
import 'package:daway_app/features/patient/domain/repositories/location_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_current_location_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  String? lastPharmacyName;
  String? lastPhone;
  String? lastRegion;
  ApiResult<void> registerResult = const Success(null);

  @override
  Future<ApiResult<String?>> sendOtp({required String phone}) async =>
      const Success(null);

  @override
  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
    String? name,
    String? birthDate,
    double? latitude,
    double? longitude,
    bool? notificationsEnabled,
  }) async =>
      const Success(PatientAuthResult(token: 'tok', isNewAccount: false));

  @override
  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) async => const Success(PharmacyAuthResult(token: 'fake-token'));

  @override
  Future<ApiResult<void>> registerPharmacy({
    required String pharmacyName,
    required String phone,
    required String region,
    required String password,
  }) async {
    lastPharmacyName = pharmacyName;
    lastPhone = phone;
    lastRegion = region;
    return registerResult;
  }

  @override
  Future<ApiResult<void>> logout({required String token}) async => const Success(null);
}

class _FakeLocationRepository implements LocationRepository {
  @override
  Future<ApiResult<PickedLocation>> getCurrentLocation() async =>
      const Success(PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة'));

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
  late _FakeAuthRepository authRepository;
  late PharmacySignUpCubit cubit;

  setUp(() {
    authRepository = _FakeAuthRepository();
    cubit = PharmacySignUpCubit(
      GetCurrentLocationUseCase(_FakeLocationRepository()),
      RegisterPharmacyUseCase(authRepository),
    );
    cubit.detailsChanged(
      pharmacyName: 'صيدلية الأمل',
      phone: '0592067456',
      address: 'الزيتون',
      password: 'secret1234',
    );
  });

  tearDown(() => cubit.close());

  group('register', () {
    test('sends the collected details, mapping address to region', () async {
      await cubit.register();

      expect(authRepository.lastPharmacyName, 'صيدلية الأمل');
      expect(authRepository.lastPhone, '0592067456');
      expect(authRepository.lastRegion, 'الزيتون');
    });

    test('marks the account as registered on success', () async {
      await cubit.register();

      expect(cubit.state.registered, isTrue);
      expect(cubit.state.isRegistering, isFalse);
      expect(cubit.state.registerError, isNull);
    });

    test('surfaces the failure message and does not mark as registered', () async {
      authRepository.registerResult =
          const ApiError(ApiFailure(message: 'رقم الهاتف مستخدم مسبقاً', statusCode: 422));

      await cubit.register();

      expect(cubit.state.registered, isFalse);
      expect(cubit.state.registerError, 'رقم الهاتف مستخدم مسبقاً');
    });
  });
}
