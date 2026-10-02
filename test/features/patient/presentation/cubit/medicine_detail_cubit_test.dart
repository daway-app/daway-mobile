import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/cart_item.dart';
import 'package:daway_app/features/patient/domain/entities/favorite_medicine.dart';
import 'package:daway_app/features/patient/domain/entities/medicine_detail.dart';
import 'package:daway_app/features/patient/domain/entities/medicine_pharmacy_offer.dart';
import 'package:daway_app/features/patient/domain/repositories/cart_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/favorites_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/location_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/medicine_detail_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/add_cart_item_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/add_favorite_medicine_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_current_location_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_favorite_medicines_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_medicine_detail_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_medicine_pharmacies_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/remove_favorite_medicine_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/medicine_detail_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/medicine_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _medicine = MedicineDetail(id: 1, tradeName: 'Panadol');
const _offers = [
  MedicinePharmacyOffer(pharmacyId: 11, pharmacyName: 'صيدلية الأمل', price: 18, distanceKm: 1.2),
];

class _FakeMedicineDetailRepository implements MedicineDetailRepository {
  ApiResult<MedicineDetail> medicineResult = const Success(_medicine);
  ApiResult<List<MedicinePharmacyOffer>> pharmaciesResult = const Success(_offers);
  ApiResult<List<MedicinePharmacyOffer>>? pharmaciesResultWithCoordinates;
  double? lastLatitude;
  double? lastLongitude;

  @override
  Future<ApiResult<MedicineDetail>> getMedicineDetail({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) async {
    lastLatitude = latitude;
    lastLongitude = longitude;
    return medicineResult;
  }

  @override
  Future<ApiResult<List<MedicinePharmacyOffer>>> getMedicinePharmacies({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) async =>
      (latitude != null ? pharmaciesResultWithCoordinates : null) ?? pharmaciesResult;
}

class _FakeCartRepository implements CartRepository {

  @override
  Future<ApiResult<void>> deleteItem({required String token, required int itemId}) async =>
      const Success(null);

  @override
  Future<ApiResult<void>> clearCart({required String token}) async => const Success(null);
  ApiResult<void> addResult = const Success(null);
  int? lastPharmacyMedicineId;
  int? lastPharmacyId;
  int? lastMedicineId;

  @override
  Future<ApiResult<void>> addItem({
    required String token,
    int? pharmacyMedicineId,
    required int pharmacyId,
    required int medicineId,
    required int quantity,
  }) async {
    lastPharmacyMedicineId = pharmacyMedicineId;
    lastPharmacyId = pharmacyId;
    lastMedicineId = medicineId;
    return addResult;
  }

  @override
  Future<ApiResult<List<CartItem>>> getItems({required String token}) async => const Success([]);

  @override
  Future<ApiResult<void>> updateQuantity({
    required String token,
    required int itemId,
    required int quantity,
  }) async =>
      const Success(null);
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

class _FakeFavoritesRepository implements FavoritesRepository {
  ApiResult<void> addResult = const Success(null);
  ApiResult<void> removeResult = const Success(null);
  ApiResult<List<FavoriteMedicine>> favoritesResult = const Success([]);
  int? lastAddedMedicineId;
  int? lastRemovedMedicineId;

  @override
  Future<ApiResult<List<FavoriteMedicine>>> getFavoriteMedicines({required String token}) async =>
      favoritesResult;

  @override
  Future<ApiResult<void>> addFavoriteMedicine({
    required String token,
    required int medicineId,
  }) async {
    lastAddedMedicineId = medicineId;
    return addResult;
  }

  @override
  Future<ApiResult<void>> removeFavoriteMedicine({
    required String token,
    required int medicineId,
  }) async {
    lastRemovedMedicineId = medicineId;
    return removeResult;
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

void main() {
  late _FakeMedicineDetailRepository medicineDetailRepository;
  late _FakeLocationRepository locationRepository;
  late _FakeFavoritesRepository favoritesRepository;
  late _FakeSessionRepository sessionRepository;
  late _FakeCartRepository cartRepository;

  MedicineDetailCubit buildCubit() {
    return MedicineDetailCubit(
      1,
      GetMedicineDetailUseCase(medicineDetailRepository),
      GetMedicinePharmaciesUseCase(medicineDetailRepository),
      GetCurrentLocationUseCase(locationRepository),
      GetFavoriteMedicinesUseCase(favoritesRepository, sessionRepository),
      AddFavoriteMedicineUseCase(favoritesRepository, sessionRepository),
      RemoveFavoriteMedicineUseCase(favoritesRepository, sessionRepository),
      AddCartItemUseCase(cartRepository, sessionRepository),
    );
  }

  setUp(() {
    medicineDetailRepository = _FakeMedicineDetailRepository();
    locationRepository = _FakeLocationRepository();
    favoritesRepository = _FakeFavoritesRepository();
    sessionRepository = _FakeSessionRepository();
    cartRepository = _FakeCartRepository();
  });

  test('loads the medicine and its pharmacies, passing the device location through', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<MedicineDetailLoaded>());
    final state = cubit.state as MedicineDetailLoaded;
    expect(state.medicine.tradeName, 'Panadol');
    expect(state.pharmacies, _offers);
    expect(state.isFavorite, isFalse);
    expect(medicineDetailRepository.lastLatitude, 31.5);
    expect(medicineDetailRepository.lastLongitude, 34.46);
  });

  test('a medicine already favorited elsewhere loads with isFavorite already true', () async {
    favoritesRepository.favoritesResult = const Success([
      FavoriteMedicine(medicineId: 1, tradeName: 'Panadol', isAvailable: true, pharmaciesCount: 1),
    ]);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect((cubit.state as MedicineDetailLoaded).isFavorite, isTrue);
  });

  test('a failed favorites fetch defaults isFavorite to false instead of failing the screen',
      () async {
    favoritesRepository.favoritesResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<MedicineDetailLoaded>());
    expect((cubit.state as MedicineDetailLoaded).isFavorite, isFalse);
  });

  test('a denied/unavailable location still loads the medicine, just without coordinates',
      () async {
    locationRepository.currentLocationResult =
        const ApiError(PermissionFailure('يرجى السماح بالوصول لموقعك'));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<MedicineDetailLoaded>());
    expect(medicineDetailRepository.lastLatitude, isNull);
    expect(medicineDetailRepository.lastLongitude, isNull);
  });

  test('a medicine-fetch failure surfaces as a load failure', () async {
    medicineDetailRepository.medicineResult =
        const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<MedicineDetailLoadFailure>());
    expect((cubit.state as MedicineDetailLoadFailure).message, 'تعذر الاتصال بالخادم');
  });

  test('a pharmacies-fetch failure still shows the medicine, with an empty pharmacy list',
      () async {
    medicineDetailRepository.pharmaciesResult =
        const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<MedicineDetailLoaded>());
    expect((cubit.state as MedicineDetailLoaded).pharmacies, isEmpty);
  });

  test('an empty pharmacy list near the patient is retried without coordinates', () async {
    medicineDetailRepository.pharmaciesResultWithCoordinates = const Success([]);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect((cubit.state as MedicineDetailLoaded).pharmacies, _offers);
  });

  group('addToCart', () {
    test('sends the offer pharmacy_medicine_id and returns null', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      final error = await cubit.addToCart(
        const MedicinePharmacyOffer(
          pharmacyId: 11,
          pharmacyName: 'صيدلية الأمل',
          price: 18,
          pharmacyMedicineId: 5,
        ),
      );

      expect(error, isNull);
      expect(cartRepository.lastPharmacyMedicineId, 5);
    });

    test('an offer without a pharmacy_medicine_id sends the pharmacy and medicine instead',
        () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      final error = await cubit.addToCart(_offers.first);

      expect(error, isNull);
      expect(cartRepository.lastPharmacyMedicineId, isNull);
      expect(cartRepository.lastPharmacyId, 11);
      expect(cartRepository.lastMedicineId, 1);
    });

    test('surfaces the server failure message', () async {
      cartRepository.addResult = const ApiError(ApiFailure(message: 'الكمية غير متوفرة'));
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      final error = await cubit.addToCart(
        const MedicinePharmacyOffer(
          pharmacyId: 11,
          pharmacyName: 'صيدلية الأمل',
          price: 18,
          pharmacyMedicineId: 5,
        ),
      );

      expect(error, 'الكمية غير متوفرة');
    });
  });

  group('toggleFavorite', () {
    test('adds then removes the medicine, flipping isFavorite each time', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      final firstError = await cubit.toggleFavorite();
      expect(firstError, isNull);
      expect((cubit.state as MedicineDetailLoaded).isFavorite, isTrue);

      final secondError = await cubit.toggleFavorite();
      expect(secondError, isNull);
      expect((cubit.state as MedicineDetailLoaded).isFavorite, isFalse);
    });

    test('starting already-favorited (loaded via getFavoriteMedicines) removes, not adds',
        () async {
      favoritesRepository.favoritesResult = const Success([
        FavoriteMedicine(
          medicineId: 1,
          tradeName: 'Panadol',
          isAvailable: true,
          pharmaciesCount: 1,
        ),
      ]);
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);
      expect((cubit.state as MedicineDetailLoaded).isFavorite, isTrue);

      final error = await cubit.toggleFavorite();

      expect(error, isNull);
      expect(favoritesRepository.lastRemovedMedicineId, 1);
      expect(favoritesRepository.lastAddedMedicineId, isNull);
      expect((cubit.state as MedicineDetailLoaded).isFavorite, isFalse);
    });

    test('a failure leaves isFavorite unchanged and returns a message for a snackbar', () async {
      favoritesRepository.addResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      final error = await cubit.toggleFavorite();

      expect(error, 'تعذر الاتصال بالخادم');
      final state = cubit.state as MedicineDetailLoaded;
      expect(state.isFavorite, isFalse);
      expect(state.isTogglingFavorite, isFalse);
    });
  });
}
