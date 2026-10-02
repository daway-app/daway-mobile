import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/cart_item.dart';
import 'package:daway_app/features/patient/domain/entities/order.dart';
import 'package:daway_app/features/patient/domain/entities/patient_address.dart';
import 'package:daway_app/features/patient/domain/entities/patient_profile.dart';
import 'package:daway_app/features/patient/domain/repositories/cart_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/orders_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_addresses_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_profile_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/checkout_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/create_patient_address_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/clear_cart_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/delete_cart_item_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_cart_items_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_addresses_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_profile_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/cart_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/checkout_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

const _items = [
  CartItem(
    id: 1,
    medicineName: 'أموكسيسيلين',
    pharmacyId: 11,
    pharmacyName: 'صيدلية النور',
    price: 18,
    quantity: 1,
  ),
  CartItem(
    id: 2,
    medicineName: 'باراسيتامول',
    pharmacyId: 12,
    pharmacyName: 'صيدلية الأمل',
    price: 12,
    quantity: 2,
  ),
];

const _address = PatientAddress(
  id: 1,
  label: 'المنزل',
  recipientName: 'مريض تجريبي',
  phone: '0599112233',
  address: 'غزة',
  latitude: 31.5,
  longitude: 34.47,
  isDefault: true,
);

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
  ApiResult<List<CartItem>> itemsResult = const Success(_items);

  @override
  Future<ApiResult<List<CartItem>>> getItems({required String token}) async => itemsResult;

  @override
  Future<ApiResult<void>> updateQuantity({
    required String token,
    required int itemId,
    required int quantity,
  }) async {
    final items = (itemsResult as Success<List<CartItem>>).data;
    itemsResult = Success([
      for (final item in items)
        if (item.id == itemId)
          CartItem(
            id: item.id,
            medicineName: item.medicineName,
            pharmacyId: item.pharmacyId,
            pharmacyName: item.pharmacyName,
            price: item.price,
            quantity: quantity,
          )
        else
          item,
    ]);
    return const Success(null);
  }
}

class _FakeAddressesRepository implements PatientAddressesRepository {

  @override
  Future<ApiResult<void>> deleteAddress({required String token, required int addressId}) async =>
      const Success(null);
  ApiResult<List<PatientAddress>> addressesResult = const Success([]);
  ApiResult<PatientAddress> createResult = const Success(_address);

  @override
  Future<ApiResult<List<PatientAddress>>> getAddresses({required String token}) async =>
      addressesResult;

  @override
  Future<ApiResult<PatientAddress>> createAddress({
    required String token,
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    bool isDefault = true,
  }) async =>
      createResult;

  @override
  Future<ApiResult<PatientAddress>> updateAddress({
    required String token,
    required int addressId,
    required String label,
    required String recipientName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required bool isDefault,
  }) async =>
      createResult;
}

class _FakeProfileRepository implements PatientProfileRepository {
  @override
  Future<ApiResult<PatientProfile>> getProfile({required String token}) async =>
      const Success(PatientProfile(name: 'مريض تجريبي', phone: '0599112233'));

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PatientProfile profile,
  }) async =>
      const Success(null);
}

class _FakeOrdersRepository implements OrdersRepository {

  @override
  Future<ApiResult<void>> cancelOrder({required String token, required int orderId}) async =>
      const Success(null);
  ApiResult<int> checkoutResult = const Success(1);
  int? lastAddressId;

  @override
  Future<ApiResult<List<Order>>> getOrders({required String token}) async => const Success([]);

  @override
  Future<ApiResult<int>> checkout({
    required String token,
    required int addressId,
    String? couponCode,
    String? notes,
  }) async {
    lastAddressId = addressId;
    return checkoutResult;
  }
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');

  @override
  Future<void> saveSession(UserSession session) async => savedSession = session;

  @override
  Future<UserSession?> getSession() async => savedSession;

  @override
  Future<void> clearSession() async => savedSession = null;
}

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final getIt = GetIt.instance;
  late _FakeCartRepository cartRepository;
  late _FakeAddressesRepository addressesRepository;
  late _FakeOrdersRepository ordersRepository;
  late _FakeSessionRepository sessionRepository;

  setUp(() {
    cartRepository = _FakeCartRepository();
    addressesRepository = _FakeAddressesRepository();
    ordersRepository = _FakeOrdersRepository();
    sessionRepository = _FakeSessionRepository();

    getIt.registerFactory<CartCubit>(
      () => CartCubit(
        GetCartItemsUseCase(cartRepository, sessionRepository),
        UpdateCartItemQuantityUseCase(cartRepository, sessionRepository),
        DeleteCartItemUseCase(cartRepository, sessionRepository),
        ClearCartUseCase(cartRepository, sessionRepository),
      ),
    );
    getIt.registerFactory<CheckoutCubit>(
      () => CheckoutCubit(
        GetPatientAddressesUseCase(addressesRepository, sessionRepository),
        CreatePatientAddressUseCase(addressesRepository, sessionRepository),
        GetPatientProfileUseCase(_FakeProfileRepository(), sessionRepository),
        CheckoutUseCase(ordersRepository, sessionRepository),
      ),
    );
  });

  tearDown(() => getIt.reset());

  Widget buildTestableScreen({List<String>? visitedRoutes, PickedLocation? pickedLocation}) {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: (settings) {
          visitedRoutes?.add(settings.name ?? '');
          if (settings.name == Routes.locationPickerScreen) {
            return MaterialPageRoute<PickedLocation>(
              builder: (_) => Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => Navigator.of(context).pop(pickedLocation),
                    child: const Text('pick'),
                  ),
                ),
              ),
            );
          }
          return MaterialPageRoute(builder: (_) => const Scaffold(body: SizedBox.shrink()));
        },
        home: const PatientCartScreen(),
      ),
    );
  }

  testWidgets('shows the header, every line and the computed total', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('السلة'), findsOneWidget);
    expect(find.textContaining('أموكسيسيلين'), findsOneWidget);
    expect(find.textContaining('باراسيتامول'), findsOneWidget);
    // 18*1 + 12*2 = 42
    expect(find.text('الاجمالي للمنتجات : 42 \$'), findsOneWidget);
  });

  testWidgets('shows the empty state and its browse button when the cart is empty',
      (tester) async {
    await setPhoneViewport(tester);
    cartRepository.itemsResult = const Success([]);
    final visitedRoutes = <String>[];

    await tester.pumpWidget(buildTestableScreen(visitedRoutes: visitedRoutes));
    await tester.pumpAndSettle();

    expect(find.text('سلتك فاضية'), findsOneWidget);
    expect(find.text('إتمام الطلب'), findsNothing);

    await tester.tap(find.text('تصفح الأقسام'));
    await tester.pumpAndSettle();

    expect(visitedRoutes, contains(Routes.allCategoriesScreen));
  });

  testWidgets('tapping + increments a line\'s quantity and the total', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    expect(find.text('2'), findsWidgets); // أموكسيسيلين's quantity is now 2
    // (18*2) + (12*2) = 60
    expect(find.text('الاجمالي للمنتجات : 60 \$'), findsOneWidget);
  });

  testWidgets('tapping - stops at a quantity of 1', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    // أموكسيسيلين already has quantity 1.
    await tester.tap(find.byIcon(Icons.remove).first);
    await tester.pumpAndSettle();

    expect(find.text('الاجمالي للمنتجات : 42 \$'), findsOneWidget);
  });

  testWidgets(
      'tapping "إتمام الطلب" with a saved default address checks out directly and refreshes the cart',
      (tester) async {
    await setPhoneViewport(tester);
    addressesRepository.addressesResult = const Success([_address]);
    cartRepository.itemsResult = const Success(_items);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    await tester.tap(find.text('إتمام الطلب'));
    await tester.pumpAndSettle();

    expect(ordersRepository.lastAddressId, 1);
    expect(find.text('تم إنشاء طلبك بنجاح'), findsOneWidget);
  });

  testWidgets(
      'tapping "إتمام الطلب" with no saved address sends the patient to pick one, then checks out',
      (tester) async {
    await setPhoneViewport(tester);
    addressesRepository.addressesResult = const Success([]);
    const location = PickedLocation(latitude: 31.5, longitude: 34.47, address: 'غزة');
    final visitedRoutes = <String>[];

    await tester.pumpWidget(
      buildTestableScreen(visitedRoutes: visitedRoutes, pickedLocation: location),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('إتمام الطلب'));
    await tester.pumpAndSettle();

    expect(visitedRoutes, contains(Routes.locationPickerScreen));
    await tester.tap(find.text('pick'));
    await tester.pumpAndSettle();

    expect(ordersRepository.lastAddressId, 1); // the address CreatePatientAddressUseCase returns
    expect(find.text('تم إنشاء طلبك بنجاح'), findsOneWidget);
  });

  testWidgets('a checkout failure shows its message instead of a fake success', (tester) async {
    await setPhoneViewport(tester);
    addressesRepository.addressesResult = const Success([_address]);
    ordersRepository.checkoutResult = const ApiError(ApiFailure(message: 'السلة فارغة'));

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    await tester.tap(find.text('إتمام الطلب'));
    await tester.pumpAndSettle();

    expect(find.text('السلة فارغة'), findsOneWidget);
  });

  testWidgets('a load failure shows the error with a working retry button', (tester) async {
    await setPhoneViewport(tester);
    cartRepository.itemsResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);

    cartRepository.itemsResult = const Success(_items);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.textContaining('أموكسيسيلين'), findsOneWidget);
  });
}
