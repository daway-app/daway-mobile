import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/cart_item.dart';
import 'package:daway_app/features/patient/domain/entities/favorite_medicine.dart';
import 'package:daway_app/features/patient/domain/entities/medicine_detail.dart';
import 'package:daway_app/features/patient/domain/entities/medicine_pharmacy_offer.dart';
import 'package:daway_app/features/patient/domain/repositories/availability_alerts_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/cart_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/favorites_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/location_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/medicine_detail_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/add_cart_item_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/subscribe_availability_alert_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/availability_alert_cubit.dart';
import 'package:daway_app/features/patient/domain/usecases/add_favorite_medicine_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_current_location_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_favorite_medicines_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_medicine_detail_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_medicine_pharmacies_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/remove_favorite_medicine_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/medicine_detail_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/medicine_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

const _medicine = MedicineDetail(id: 1, tradeName: 'أكامول 500 مج');
const _offers = [
  MedicinePharmacyOffer(pharmacyId: 11, pharmacyName: 'صيدلية النور', price: 18, distanceKm: 1.2),
  MedicinePharmacyOffer(pharmacyId: 12, pharmacyName: 'صيدلية الأمل', price: 15, distanceKm: 2.5),
];

class _FakeMedicineDetailRepository implements MedicineDetailRepository {
  ApiResult<MedicineDetail> medicineResult = const Success(_medicine);
  ApiResult<List<MedicinePharmacyOffer>> pharmaciesResult = const Success(_offers);

  @override
  Future<ApiResult<MedicineDetail>> getMedicineDetail({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) async =>
      medicineResult;

  @override
  Future<ApiResult<List<MedicinePharmacyOffer>>> getMedicinePharmacies({
    required int medicineId,
    double? latitude,
    double? longitude,
  }) async =>
      pharmaciesResult;
}

class _FakeAlertsRepository implements AvailabilityAlertsRepository {
  @override
  Future<ApiResult<void>> subscribe({required String token, required int medicineId}) async =>
      const Success(null);
}

class _FakeCartRepository implements CartRepository {

  @override
  Future<ApiResult<void>> deleteItem({required String token, required int itemId}) async =>
      const Success(null);

  @override
  Future<ApiResult<void>> clearCart({required String token}) async => const Success(null);
  @override
  Future<ApiResult<void>> addItem({
    required String token,
    int? pharmacyMedicineId,
    required int pharmacyId,
    required int medicineId,
    required int quantity,
  }) async =>
      const Success(null);

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
  @override
  Future<ApiResult<PickedLocation>> getCurrentLocation() async =>
      const Success(PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة'));

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

  @override
  Future<ApiResult<List<FavoriteMedicine>>> getFavoriteMedicines({required String token}) async =>
      const Success([]);

  @override
  Future<ApiResult<void>> addFavoriteMedicine({
    required String token,
    required int medicineId,
  }) async =>
      addResult;

  @override
  Future<ApiResult<void>> removeFavoriteMedicine({
    required String token,
    required int medicineId,
  }) async =>
      const Success(null);
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
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final getIt = GetIt.instance;
  late _FakeMedicineDetailRepository medicineDetailRepository;
  late _FakeFavoritesRepository favoritesRepository;

  setUp(() {
    medicineDetailRepository = _FakeMedicineDetailRepository();
    favoritesRepository = _FakeFavoritesRepository();
    final sessionRepository = _FakeSessionRepository();
    final locationRepository = _FakeLocationRepository();

    getIt.registerFactoryParam<AvailabilityAlertCubit, int, void>(
      (medicineId, _) => AvailabilityAlertCubit(
        medicineId,
        SubscribeAvailabilityAlertUseCase(_FakeAlertsRepository(), sessionRepository),
      ),
    );
    getIt.registerFactoryParam<MedicineDetailCubit, int, void>(
      (medicineId, _) => MedicineDetailCubit(
        medicineId,
        GetMedicineDetailUseCase(medicineDetailRepository),
        GetMedicinePharmaciesUseCase(medicineDetailRepository),
        GetCurrentLocationUseCase(locationRepository),
        GetFavoriteMedicinesUseCase(favoritesRepository, sessionRepository),
        AddFavoriteMedicineUseCase(favoritesRepository, sessionRepository),
        RemoveFavoriteMedicineUseCase(favoritesRepository, sessionRepository),
        AddCartItemUseCase(_FakeCartRepository(), sessionRepository),
      ),
    );
  });

  tearDown(() => getIt.reset());

  Widget buildTestableScreen({
    List<String>? visitedRoutes,
    void Function(RouteSettings settings)? onNavigate,
  }) {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: (settings) {
          visitedRoutes?.add(settings.name ?? '');
          onNavigate?.call(settings);
          return MaterialPageRoute(builder: (_) => const Scaffold(body: SizedBox.shrink()));
        },
        home: const MedicineDetailScreen(medicineId: 1),
      ),
    );
  }

  testWidgets('shows the medicine name and every pharmacy offer', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('أكامول 500 مج'), findsOneWidget);
    expect(find.text('صيدلية النور'), findsOneWidget);
    expect(find.text('صيدلية الأمل'), findsOneWidget);
    expect(find.text('اختر الصيدلية المناسبة لك'), findsOneWidget);
  });

  testWidgets('tapping a different pharmacy card selects it without throwing', (tester) async {
    await setPhoneViewport(tester);
    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('صيدلية الأمل'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty pharmacy list shows the fallback message instead of a blank section',
      (tester) async {
    await setPhoneViewport(tester);
    medicineDetailRepository.pharmaciesResult = const Success([]);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('لا توجد صيدليات متوفرة لهذا الدواء حالياً'), findsOneWidget);
      expect(find.text('نبّهني عند التوفر'), findsOneWidget);
  });

  testWidgets('a load failure shows the error with a working retry button', (tester) async {
    await setPhoneViewport(tester);
    medicineDetailRepository.medicineResult =
        const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);

    medicineDetailRepository.medicineResult = const Success(_medicine);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.text('أكامول 500 مج'), findsOneWidget);
  });

  testWidgets('a favorite-toggle failure shows a snackbar with the error message',
      (tester) async {
    await setPhoneViewport(tester);
    favoritesRepository.addResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('حفظ في المفضلة'));
    await tester.pumpAndSettle();

    expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);
  });

  testWidgets(
      'tapping "اسأل الصيدلية قبل الشراء" opens the chat for the selected pharmacy',
      (tester) async {
    await setPhoneViewport(tester);
    Map<String, dynamic>? capturedArgs;

    await tester.pumpWidget(
      buildTestableScreen(
        onNavigate: (settings) {
          if (settings.name == Routes.chatScreen) {
            capturedArgs = settings.arguments as Map<String, dynamic>;
          }
        },
      ),
    );
    await tester.pumpAndSettle();
    // صيدلية النور (id 11) is selected by default.
    await tester.tap(find.text('اسأل الصيدلية قبل الشراء'));
    await tester.pumpAndSettle();

    expect(capturedArgs, isNotNull);
    expect(capturedArgs!['medicineId'], 1);
    expect(capturedArgs!['subtitle'], 'أكامول 500 مج');
    expect(capturedArgs!['pharmacyId'], 11);
    expect(capturedArgs!['title'], 'صيدلية النور');
  });

  testWidgets('selecting a different pharmacy sends the inquiry to that one instead',
      (tester) async {
    await setPhoneViewport(tester);
    Map<String, dynamic>? capturedArgs;

    await tester.pumpWidget(
      buildTestableScreen(
        onNavigate: (settings) {
          if (settings.name == Routes.chatScreen) {
            capturedArgs = settings.arguments as Map<String, dynamic>;
          }
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('صيدلية الأمل'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اسأل الصيدلية قبل الشراء'));
    await tester.pumpAndSettle();

    expect(capturedArgs!['pharmacyId'], 12);
    expect(capturedArgs!['title'], 'صيدلية الأمل');
  });

  testWidgets('tapping "أضف الى السلة" adds the selected pharmacy and opens the cart',
      (tester) async {
    await setPhoneViewport(tester);
    final visited = <String>[];

    await tester.pumpWidget(buildTestableScreen(visitedRoutes: visited));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أضف الى السلة'));
    await tester.pumpAndSettle();

    expect(visited, contains(Routes.patientCartScreen));
  });
}
