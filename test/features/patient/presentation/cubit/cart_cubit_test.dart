import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/cart_item.dart';
import 'package:daway_app/features/patient/domain/repositories/cart_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/clear_cart_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/delete_cart_item_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_cart_items_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/cart_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/cart_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _item = CartItem(
  id: 7,
  medicineName: 'Panadol',
  pharmacyId: 11,
  pharmacyName: 'صيدلية النور',
  price: 18,
  quantity: 2,
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
  ApiResult<List<CartItem>> itemsResult = const Success([_item]);
  ApiResult<void> updateResult = const Success(null);
  int? lastQuantity;
  int getItemsCallCount = 0;

  @override
  Future<ApiResult<List<CartItem>>> getItems({required String token}) async {
    getItemsCallCount++;
    return itemsResult;
  }

  @override
  Future<ApiResult<void>> updateQuantity({
    required String token,
    required int itemId,
    required int quantity,
  }) async {
    lastQuantity = quantity;
    return updateResult;
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
  late _FakeCartRepository repository;
  late _FakeSessionRepository sessionRepository;

  CartCubit buildCubit() {
    return CartCubit(
      GetCartItemsUseCase(repository, sessionRepository),
      UpdateCartItemQuantityUseCase(repository, sessionRepository),
      DeleteCartItemUseCase(repository, sessionRepository),
      ClearCartUseCase(repository, sessionRepository),
    );
  }

  setUp(() {
    repository = _FakeCartRepository();
    sessionRepository = _FakeSessionRepository();
  });

  test('loads the cart items on construction', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<CartLoaded>());
    expect((cubit.state as CartLoaded).items, [_item]);
  });

  test('deleteItem removes only that line and returns null', () async {
    repository.itemsResult = const Success([
      _item,
      CartItem(
        id: 8,
        medicineName: 'Advil',
        pharmacyId: 12,
        pharmacyName: 'صيدلية الأمل',
        price: 12,
        quantity: 3,
      ),
    ]);
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.deleteItem(_item);

    expect(error, isNull);
    expect((cubit.state as CartLoaded).items.map((i) => i.id), [8]);
  });

  test('clear empties the cart and returns null', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    final error = await cubit.clear();

    expect(error, isNull);
    expect((cubit.state as CartLoaded).items, isEmpty);
  });

  test('surfaces a load failure', () async {
    repository.itemsResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<CartLoadFailure>());
  });

  test('total sums each line\'s price times its quantity', () async {
    repository.itemsResult = const Success([
      _item, // 18 * 2 = 36
      CartItem(
        id: 8,
        medicineName: 'Advil',
        pharmacyId: 12,
        pharmacyName: 'صيدلية الأمل',
        price: 12,
        quantity: 3, // 36
      ),
    ]);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await Future<void>.delayed(Duration.zero);

    expect((cubit.state as CartLoaded).total, 72);
  });

  test('incrementQuantity sends quantity + 1 and patches the line locally, without reloading',
      () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);
    final callsBeforeIncrement = repository.getItemsCallCount;

    await cubit.incrementQuantity(_item);

    expect(repository.lastQuantity, 3);
    expect((cubit.state as CartLoaded).items.single.quantity, 3);
    // No extra GET /patient/cart round-trip — the new quantity is already
    // known, so the state is patched locally instead of re-fetched.
    expect(repository.getItemsCallCount, callsBeforeIncrement);
  });

  test('decrementQuantity sends quantity - 1', () async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    await cubit.decrementQuantity(_item);

    expect(repository.lastQuantity, 1);
  });

  test('decrementQuantity does nothing once quantity is already 1 (no delete affordance)',
      () async {
    const singleItem = CartItem(
      id: 7,
      medicineName: 'Panadol',
      pharmacyId: 11,
      pharmacyName: 'صيدلية النور',
      price: 18,
      quantity: 1,
    );
    repository.itemsResult = const Success([singleItem]);
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    await cubit.decrementQuantity(singleItem);

    expect(repository.lastQuantity, isNull);
    expect((cubit.state as CartLoaded).items.single.quantity, 1);
  });

  test('a quantity-update failure clears updatingIds instead of leaving the row stuck',
      () async {
    repository.updateResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    await cubit.incrementQuantity(_item);

    final state = cubit.state as CartLoaded;
    expect(state.updatingIds, isEmpty);
    // The failed update didn't get applied locally either.
    expect(state.items.single.quantity, 2);
  });
}
