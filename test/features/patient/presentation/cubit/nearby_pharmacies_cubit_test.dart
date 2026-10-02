import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/features/patient/domain/entities/nearby_pharmacy.dart';
import 'package:daway_app/features/patient/domain/repositories/location_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/pharmacies_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_current_location_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_nearby_pharmacies_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_pharmacy_working_hours_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/nearby_pharmacies_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/nearby_pharmacies_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _pharmacies = [
  NearbyPharmacy(id: 1, name: 'صيدلية الأمل', latitude: 31.5, longitude: 34.46, isOpenNow: true),
  NearbyPharmacy(id: 2, name: 'صيدلية الشفاء', latitude: 32.2, longitude: 35.2, isOpenNow: false),
];

class _FakePharmaciesRepository implements PharmaciesRepository {
  ApiResult<List<NearbyPharmacy>> listResult = const Success(_pharmacies);
  ApiResult<String?> hoursResult = const Success('9 ص - 10 م');
  double? lastLatitude;

  @override
  Future<ApiResult<List<NearbyPharmacy>>> getNearbyPharmacies({
    double? userLatitude,
    double? userLongitude,
  }) async {
    lastLatitude = userLatitude;
    return listResult;
  }

  @override
  Future<ApiResult<String?>> getWorkingHoursLabel(int pharmacyId) async => hoursResult;
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
  }) async =>
      const Success('');

  @override
  Future<ApiResult<PickedLocation>> searchAddress(String query) async =>
      const ApiError(ValidationFailure('لم يتم العثور على هذا العنوان'));
}

void main() {
  late _FakePharmaciesRepository pharmaciesRepository;
  late _FakeLocationRepository locationRepository;

  NearbyPharmaciesCubit buildCubit() {
    return NearbyPharmaciesCubit(
      GetNearbyPharmaciesUseCase(pharmaciesRepository),
      GetCurrentLocationUseCase(locationRepository),
      GetPharmacyWorkingHoursUseCase(pharmaciesRepository),
    );
  }

  setUp(() {
    pharmaciesRepository = _FakePharmaciesRepository();
    locationRepository = _FakeLocationRepository();
  });

  test('loads the pharmacies, passing the device location through', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<NearbyPharmaciesLoaded>());
    final state = cubit.state as NearbyPharmaciesLoaded;
    expect(state.pharmacies, _pharmacies);
    expect(pharmaciesRepository.lastLatitude, 31.5);
  });

  test('a load failure surfaces as NearbyPharmaciesLoadFailure', () async {
    pharmaciesRepository.listResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<NearbyPharmaciesLoadFailure>());
  });

  test('searchChanged filters visiblePharmacies by name, case-sensitively as typed', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    cubit.searchChanged('الشفاء');

    final state = cubit.state as NearbyPharmaciesLoaded;
    expect(state.visiblePharmacies, hasLength(1));
    expect(state.visiblePharmacies.single.name, 'صيدلية الشفاء');
  });

  test('selectPharmacy opens the sheet immediately, then fills in the hours', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    final future = cubit.selectPharmacy(_pharmacies.first);
    // Right after calling, the sheet is already open (optimistic), loading hours.
    var state = cubit.state as NearbyPharmaciesLoaded;
    expect(state.selectedPharmacy?.id, 1);
    expect(state.isLoadingHours, isTrue);

    await future;
    state = cubit.state as NearbyPharmaciesLoaded;
    expect(state.isLoadingHours, isFalse);
    expect(state.selectedWorkingHours, '9 ص - 10 م');
  });

  test('a hours-fetch failure leaves the sheet open with no hours line', () async {
    pharmaciesRepository.hoursResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    await cubit.selectPharmacy(_pharmacies.first);

    final state = cubit.state as NearbyPharmaciesLoaded;
    expect(state.selectedPharmacy?.id, 1);
    expect(state.selectedWorkingHours, isNull);
  });

  test('clearSelection closes the sheet', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);
    await cubit.selectPharmacy(_pharmacies.first);

    cubit.clearSelection();

    final state = cubit.state as NearbyPharmaciesLoaded;
    expect(state.selectedPharmacy, isNull);
    expect(state.selectedWorkingHours, isNull);
  });
}
