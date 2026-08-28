import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/inventory_item_update.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_inventory_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_inventory_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

const _medicine = Medicine(
  id: 1,
  medicineId: 5,
  name: 'Panadol',
  activeIngredient: 'Paracetamol 500mg',
  price: 12,
  quantity: 120,
  isAvailable: true,
);

class _FakePharmacyInventoryRepository implements PharmacyInventoryRepository {
  String? lastToken;
  ApiResult<List<Medicine>> getResult = const Success([_medicine]);

  @override
  Future<ApiResult<List<Medicine>>> getInventory({required String token}) async {
    lastToken = token;
    return getResult;
  }

  @override
  Future<ApiResult<void>> updateInventory({
    required String token,
    required List<InventoryItemUpdate> items,
  }) async {
    throw UnimplementedError();
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
  late GetPharmacyInventoryUseCase useCase;

  setUp(() {
    repository = _FakePharmacyInventoryRepository();
    sessionRepository = _FakeSessionRepository();
    useCase = GetPharmacyInventoryUseCase(repository, sessionRepository);
  });

  test('fails without hitting the repository when there is no saved session', () async {
    final result = await useCase();

    expect(result, isA<ApiError<List<Medicine>>>());
    expect(repository.lastToken, isNull);
  });

  test('fetches inventory using the saved session token', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');

    final result = await useCase();

    expect(result, isA<Success<List<Medicine>>>());
    expect(repository.lastToken, 'tok-1');
  });

  test('surfaces a repository failure', () async {
    sessionRepository.savedSession =
        const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');
    repository.getResult = const ApiError(NetworkFailure('لا يوجد اتصال بالإنترنت'));

    final result = await useCase();

    expect(result, isA<ApiError<List<Medicine>>>());
  });
}
