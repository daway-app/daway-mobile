import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/inventory_item_update.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_inventory_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/update_pharmacy_inventory_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePharmacyInventoryRepository implements PharmacyInventoryRepository {
  String? lastToken;
  List<InventoryItemUpdate>? lastItems;
  ApiResult<void> updateResult = const Success(null);

  @override
  Future<ApiResult<List<Medicine>>> getInventory({required String token}) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> updateInventory({
    required String token,
    required List<InventoryItemUpdate> items,
  }) async {
    lastToken = token;
    lastItems = items;
    return updateResult;
  }
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

void main() {
  late _FakePharmacyInventoryRepository repository;
  late _FakeSessionRepository sessionRepository;
  late UpdatePharmacyInventoryUseCase useCase;

  const items = [
    InventoryItemUpdate(pharmacyMedicineId: 1, quantity: 50, isAvailable: true),
    InventoryItemUpdate(pharmacyMedicineId: 2, quantity: 0, isAvailable: false),
  ];

  setUp(() {
    repository = _FakePharmacyInventoryRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = UpdatePharmacyInventoryUseCase(repository, sessionRepository);
  });

  test('fails without hitting the repository when there is no saved session', () async {
    final result = await useCase(items);

    expect(result, isA<ApiError<void>>());
    expect(repository.lastToken, isNull);
  });

  test('updates the inventory using the saved session token', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');

    final result = await useCase(items);

    expect(result, isA<Success<void>>());
    expect(repository.lastToken, 'tok-1');
    expect(repository.lastItems, items);
  });

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');
    repository.updateResult = const ApiError(ApiFailure(message: 'فشل التحديث'));

    final result = await useCase(items);

    expect(result, isA<ApiError<void>>());
  });
}
