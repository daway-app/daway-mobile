import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/features/patient/domain/repositories/location_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_current_location_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/home_location_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocationRepository implements LocationRepository {
  ApiResult<PickedLocation> result =
      const Success(PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة - الرمال'));

  @override
  Future<ApiResult<PickedLocation>> getCurrentLocation() async => result;

  @override
  Future<ApiResult<String>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async =>
      const Success('');

  @override
  Future<ApiResult<PickedLocation>> searchAddress(String query) async =>
      const ApiError(ValidationFailure('لم يتم العثور على هذا العنوان'));
}

void main() {
  late _FakeLocationRepository repository;

  HomeLocationCubit build() => HomeLocationCubit(GetCurrentLocationUseCase(repository));

  setUp(() => repository = _FakeLocationRepository());

  test('shows the address of the device position', () async {
    final cubit = build();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, 'غزة - الرمال');
  });

  test('a denied permission leaves the address unknown', () async {
    repository.result = const ApiError(PermissionFailure('يرجى السماح بالوصول لموقعك'));
    final cubit = build();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isNull);
  });

  test('a position with no reverse-geocoded address stays unknown', () async {
    repository.result =
        const Success(PickedLocation(latitude: 31.5, longitude: 34.46, address: ''));
    final cubit = build();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isNull);
  });
}
