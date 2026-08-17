import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/picked_location.dart';
import 'package:daway_app/features/patient/domain/repositories/location_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_current_location_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/reverse_geocode_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/search_address_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/location_picker_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocationRepository implements LocationRepository {
  ApiResult<PickedLocation> currentLocationResult =
      const Success(PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة'));
  ApiResult<String> reverseGeocodeResult = const Success('غزة - الرمال');
  ApiResult<PickedLocation> searchResult =
      const Success(PickedLocation(latitude: 24.7, longitude: 46.6, address: 'الرياض'));

  @override
  Future<ApiResult<PickedLocation>> getCurrentLocation() async => currentLocationResult;

  @override
  Future<ApiResult<String>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async =>
      reverseGeocodeResult;

  @override
  Future<ApiResult<PickedLocation>> searchAddress(String query) async => searchResult;
}

void main() {
  late _FakeLocationRepository repository;
  late LocationPickerCubit cubit;

  setUp(() {
    repository = _FakeLocationRepository();
    cubit = LocationPickerCubit(
      GetCurrentLocationUseCase(repository),
      ReverseGeocodeUseCase(repository),
      SearchAddressUseCase(repository),
      initialLatitude: 31.5017,
      initialLongitude: 34.4668,
    );
  });

  tearDown(() => cubit.close());

  test('starts at the given initial coordinates', () {
    expect(cubit.state.latitude, 31.5017);
    expect(cubit.state.longitude, 34.4668);
    expect(cubit.state.address, isNull);
  });

  test('pinMoved updates coordinates without resolving the address by itself', () {
    cubit.pinMoved(30.0, 35.0);

    expect(cubit.state.latitude, 30.0);
    expect(cubit.state.longitude, 35.0);
  });

  test('resolveAddressForCurrentPin fills in the address for the current pin', () async {
    cubit.pinMoved(30.0, 35.0);

    await cubit.resolveAddressForCurrentPin();

    expect(cubit.state.address, 'غزة - الرمال');
    expect(cubit.state.isResolvingAddress, isFalse);
  });

  group('useCurrentLocation', () {
    test('moves the pin to the device location on success', () async {
      await cubit.useCurrentLocation();

      expect(cubit.state.latitude, 31.5);
      expect(cubit.state.longitude, 34.46);
      expect(cubit.state.address, 'غزة');
      expect(cubit.state.isLocating, isFalse);
    });

    test('surfaces a permission error without moving the pin', () async {
      repository.currentLocationResult =
          const ApiError(PermissionFailure('يرجى السماح بالوصول لموقعك'));

      await cubit.useCurrentLocation();

      expect(cubit.state.latitude, 31.5017);
      expect(cubit.state.errorMessage, 'يرجى السماح بالوصول لموقعك');
    });
  });

  group('search', () {
    test('does nothing for a blank query', () async {
      await cubit.search('   ');

      expect(cubit.state.latitude, 31.5017);
      expect(cubit.state.isSearching, isFalse);
    });

    test('moves the pin to the matched address on success', () async {
      await cubit.search('الرياض');

      expect(cubit.state.latitude, 24.7);
      expect(cubit.state.longitude, 46.6);
      expect(cubit.state.address, 'الرياض');
    });

    test('surfaces an error when nothing is found', () async {
      repository.searchResult = const ApiError(ValidationFailure('لم يتم العثور على هذا العنوان'));

      await cubit.search('unknown place');

      expect(cubit.state.errorMessage, 'لم يتم العثور على هذا العنوان');
    });
  });
}
