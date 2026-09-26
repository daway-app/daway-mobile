import 'dart:async';

import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/core/widgets/header_icon_button.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/inventory_item_update.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine_catalog_item.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_inventory_repository.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_medicine_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/delete_pharmacy_medicine_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_medicines_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/update_pharmacy_inventory_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_medicines_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_products_screen.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/pharmacy_dashboard_tab_scope.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/product_card.dart';
import 'package:daway_app/features/pharmacy/presentation/widgets/product_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

const _amoxicillin = Medicine(
  id: 1,
  medicineId: 5,
  name: 'Amoxicillin',
  nameAr: 'أموكسيسيلين 500 مج',
  activeIngredient: 'مضادات حيوية',
  price: 18,
  quantity: 120,
  isAvailable: true,
);
const _ceftriaxone = Medicine(
  id: 2,
  medicineId: 6,
  name: 'Ceftriaxone',
  nameAr: 'سيفترياكسون 1 غ',
  activeIngredient: 'مضادات حيوية',
  price: 25,
  quantity: 8,
  isAvailable: true,
);
const _clindamycin = Medicine(
  id: 3,
  medicineId: 7,
  name: 'Clindamycin',
  nameAr: 'كليندامايسين 300 مج',
  activeIngredient: 'مضادات حيوية',
  price: 20,
  quantity: 0,
  isAvailable: true,
);

class _FakeMedicineRepository implements PharmacyMedicineRepository {
  ApiResult<List<Medicine>> result = const Success([_amoxicillin, _ceftriaxone, _clindamycin]);
  int fetches = 0;

  /// When set, a fetch waits for it — keeps the page loading as long as a test
  /// needs.
  Completer<void>? gate;

  @override
  Future<ApiResult<List<Medicine>>> getMedicines({required String token}) async {
    fetches++;
    final pending = gate;
    if (pending != null) await pending.future;
    return result;
  }

  @override
  Future<ApiResult<List<MedicineCatalogItem>>> searchCatalog({
    required String token,
    required String query,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> addMedicine({
    required String token,
    int? medicineId,
    int? mohMedicineId,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? imageUrl,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> addMedicineByName({
    required String token,
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
    required double price,
    required int quantity,
    required bool isAvailable,
    String? imageUrl,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> deleteMedicine({
    required String token,
    required int pharmacyMedicineId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> updateMedicine({
    required String token,
    required int pharmacyMedicineId,
    required int medicineId,
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
    required double price,
    required int quantity,
    required bool isAvailable,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeInventoryRepository implements PharmacyInventoryRepository {
  ApiResult<void> updateResult = const Success(null);
  final List<List<InventoryItemUpdate>> requests = [];

  @override
  Future<ApiResult<List<Medicine>>> getInventory({required String token}) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<void>> updateInventory({
    required String token,
    required List<InventoryItemUpdate> items,
  }) async {
    requests.add(items);
    return updateResult;
  }
}

class _FakeSessionRepository implements SessionRepository {
  @override
  Future<void> saveSession(UserSession session) async {}

  @override
  Future<UserSession?> getSession() async =>
      const UserSession(accountType: AccountType.pharmacy, token: 'tok-1');

  @override
  Future<void> clearSession() async {}
}

void main() {
  late _FakeMedicineRepository medicineRepository;
  late _FakeInventoryRepository inventoryRepository;
  late List<PharmacyDashboardTab> switchedTabs;
  late List<RouteSettings> pushedRoutes;

  /// What the add and edit routes answer when they close.
  Object? routeResult;

  setUp(() {
    medicineRepository = _FakeMedicineRepository();
    inventoryRepository = _FakeInventoryRepository();
    switchedTabs = [];
    pushedRoutes = [];
    routeResult = null;
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await setDesignViewport(tester);
    final sessionRepository = _FakeSessionRepository();
    await tester.pumpWidget(
      buildArabicTestApp(
        onGenerateRoute: (settings) {
          pushedRoutes.add(settings);
          return MaterialPageRoute<Object?>(
            settings: settings,
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(routeResult),
                  child: Text('page ${settings.name}'),
                ),
              ),
            ),
          );
        },
        home: BlocProvider(
          create: (_) => PharmacyMedicinesCubit(
            GetPharmacyMedicinesUseCase(medicineRepository, sessionRepository),
            DeletePharmacyMedicineUseCase(medicineRepository, sessionRepository),
            UpdatePharmacyInventoryUseCase(inventoryRepository, sessionRepository),
          ),
          child: PharmacyDashboardTabScope(
            switchToTab: switchedTabs.add,
            child: const PharmacyProductsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder cardFor(String name) => find.ancestor(of: find.text(name), matching: find.byType(ProductCard));

  Finder buttonIn(Finder card, String label) => find.descendant(
        of: card,
        matching: find.bySemanticsLabel(label),
      );

  testWidgets('has the back chip, the title and the line under it', (tester) async {
    await pumpScreen(tester);

    expect(find.text('اجمالي المنتجات'), findsOneWidget);
    expect(find.text('أدر المنتجات الخاصة بك'), findsOneWidget);
  });

  testWidgets('shows a card for every medicine, with the count on الكل', (tester) async {
    await pumpScreen(tester);

    expect(find.byType(ProductCard), findsNWidgets(3));
    expect(find.text('الكل(3)'), findsOneWidget);
    expect(find.text('أموكسيسيلين 500 مج'), findsOneWidget);
    expect(find.text('سيفترياكسون 1 غ'), findsOneWidget);
    expect(find.text('كليندامايسين 300 مج'), findsOneWidget);
  });

  testWidgets('the badges say متوفر, مخزون منخفض and نافد', (tester) async {
    await pumpScreen(tester);

    // The chips carry the same words, so look inside the cards only.
    expect(find.descendant(of: cardFor('أموكسيسيلين 500 مج'), matching: find.text('متوفر')), findsOneWidget);
    expect(find.descendant(of: cardFor('سيفترياكسون 1 غ'), matching: find.text('مخزون منخفض')), findsOneWidget);
    expect(find.descendant(of: cardFor('كليندامايسين 300 مج'), matching: find.text('نافد')), findsOneWidget);
  });

  group('loading and failing', () {
    Future<void> pumpUntilLoadingOrFailed(WidgetTester tester) async {
      await setDesignViewport(tester);
      final sessionRepository = _FakeSessionRepository();
      await tester.pumpWidget(
        buildArabicTestApp(
          home: BlocProvider(
            create: (_) => PharmacyMedicinesCubit(
              GetPharmacyMedicinesUseCase(medicineRepository, sessionRepository),
              DeletePharmacyMedicineUseCase(medicineRepository, sessionRepository),
              UpdatePharmacyInventoryUseCase(inventoryRepository, sessionRepository),
            ),
            child: PharmacyDashboardTabScope(
              switchToTab: switchedTabs.add,
              child: const PharmacyProductsScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('a spinner under the title while the list is on its way', (tester) async {
      medicineRepository.gate = Completer<void>();

      await pumpUntilLoadingOrFailed(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('اجمالي المنتجات'), findsOneWidget);
      expect(find.byType(ProductCard), findsNothing);
      expect(find.byType(ProductFilterChips), findsNothing);
    });

    testWidgets('a failure shows its message, and retrying loads the list', (tester) async {
      medicineRepository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));
      await pumpUntilLoadingOrFailed(tester);
      expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);
      expect(find.byType(ProductCard), findsNothing);

      medicineRepository.result = const Success([_amoxicillin]);
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pumpAndSettle();

      expect(find.byType(ProductCard), findsOneWidget);
    });
  });

  group('filtering', () {
    testWidgets('a chip narrows the cards to that status', (tester) async {
      await pumpScreen(tester);

      // The test font is wider than Tajawal, so this chip can be out of sight.
      final outOfStock = find.descendant(of: find.byType(ProductFilterChips), matching: find.text('نافد'));
      await tester.ensureVisible(outOfStock);
      await tester.tap(outOfStock);
      await tester.pump();

      expect(find.byType(ProductCard), findsOneWidget);
      expect(find.text('كليندامايسين 300 مج'), findsOneWidget);
      // The count stays the pharmacy's whole list.
      expect(find.text('الكل(3)'), findsOneWidget);
    });

    testWidgets('الكل shows everything again', (tester) async {
      await pumpScreen(tester);
      await tester.tap(find.descendant(of: find.byType(ProductFilterChips), matching: find.text('متوفر')));
      await tester.pump();
      expect(find.byType(ProductCard), findsOneWidget);

      await tester.tap(find.text('الكل(3)'));
      await tester.pump();

      expect(find.byType(ProductCard), findsNWidgets(3));
    });

    testWidgets('typing in the search box narrows the cards to the matches', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField), 'سيفتر');
      await tester.pump();

      expect(find.byType(ProductCard), findsOneWidget);
      expect(find.text('سيفترياكسون 1 غ'), findsOneWidget);
    });

    testWidgets('a search that matches nothing says so', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pump();

      expect(find.byType(ProductCard), findsNothing);
      expect(find.text('لا توجد منتجات مطابقة'), findsOneWidget);
    });

    testWidgets('a pharmacy with no medicines says it has none yet', (tester) async {
      medicineRepository.result = const Success([]);

      await pumpScreen(tester);

      expect(find.text('لا توجد منتجات بعد'), findsOneWidget);
      expect(find.text('الكل(0)'), findsOneWidget);
      // Adding one is still possible.
      expect(find.text('أضف منتج جديد'), findsOneWidget);
    });
  });

  group('the stepper', () {
    testWidgets('plus raises the number at once and saves it', (tester) async {
      await pumpScreen(tester);
      final semantics = tester.ensureSemantics();

      await tester.tap(buttonIn(cardFor('أموكسيسيلين 500 مج'), 'زيادة الكمية'));
      await tester.pump();

      expect(find.text('121'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(inventoryRepository.requests, [
        [const InventoryItemUpdate(pharmacyMedicineId: 1, quantity: 121, isAvailable: true)],
      ]);
      semantics.dispose();
    });

    testWidgets('minus lowers it, and stops at zero', (tester) async {
      await pumpScreen(tester);
      final semantics = tester.ensureSemantics();

      await tester.tap(buttonIn(cardFor('سيفترياكسون 1 غ'), 'إنقاص الكمية'));
      await tester.pumpAndSettle();
      expect(find.text('7'), findsOneWidget);

      await tester.tap(buttonIn(cardFor('كليندامايسين 300 مج'), 'إنقاص الكمية'));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
      expect(inventoryRepository.requests.length, 1);
      semantics.dispose();
    });

    testWidgets('the badge follows the quantity across the low-stock line', (tester) async {
      await pumpScreen(tester);
      final semantics = tester.ensureSemantics();

      // 8 is low; three more make 11.
      for (var i = 0; i < 3; i++) {
        await tester.tap(buttonIn(cardFor('سيفترياكسون 1 غ'), 'زيادة الكمية'));
        await tester.pumpAndSettle();
      }

      expect(find.descendant(of: cardFor('سيفترياكسون 1 غ'), matching: find.text('متوفر')), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('a failed save puts the number back and shows why', (tester) async {
      inventoryRepository.updateResult = const ApiError(ApiFailure(message: 'فشل التحديث'));
      await pumpScreen(tester);
      final semantics = tester.ensureSemantics();

      await tester.tap(buttonIn(cardFor('أموكسيسيلين 500 مج'), 'زيادة الكمية'));
      await tester.pumpAndSettle();

      expect(find.text('120'), findsOneWidget);
      expect(find.text('121'), findsNothing);
      expect(find.text('فشل التحديث'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('the actions and the way out', () {
    testWidgets('the back chip goes to الرئيسية', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byType(HeaderIconButton));

      expect(switchedTabs, [PharmacyDashboardTab.home]);
    });

    testWidgets('تحديث المنتجات goes to the inventory page', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('تحديث المنتجات'));

      expect(switchedTabs, [PharmacyDashboardTab.inventory]);
    });

    testWidgets('أضف منتج جديد opens the add page, and a medicine added there reloads the list', (
      tester,
    ) async {
      await pumpScreen(tester);
      routeResult = true;
      final fetchesBefore = medicineRepository.fetches;
      medicineRepository.result = const Success([_amoxicillin]);

      await tester.tap(find.text('أضف منتج جديد'));
      await tester.pumpAndSettle();
      expect(pushedRoutes.last.name, Routes.addPharmacyMedicineScreen);

      await tester.tap(find.text('page ${Routes.addPharmacyMedicineScreen}'));
      await tester.pumpAndSettle();

      expect(medicineRepository.fetches, fetchesBefore + 1);
      expect(find.byType(ProductCard), findsOneWidget);
    });

    testWidgets('closing the add page without adding leaves the list alone', (tester) async {
      await pumpScreen(tester);
      routeResult = null;
      final fetchesBefore = medicineRepository.fetches;

      await tester.tap(find.text('أضف منتج جديد'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('page ${Routes.addPharmacyMedicineScreen}'));
      await tester.pumpAndSettle();

      expect(medicineRepository.fetches, fetchesBefore);
    });

    testWidgets('a card opens the edit page for its medicine, and a saved edit reloads the list', (
      tester,
    ) async {
      await pumpScreen(tester);
      routeResult = true;
      final fetchesBefore = medicineRepository.fetches;

      await tester.tap(find.text('سيفترياكسون 1 غ'));
      await tester.pumpAndSettle();
      expect(pushedRoutes.last.name, Routes.editPharmacyMedicineScreen);
      expect(pushedRoutes.last.arguments, _ceftriaxone);

      await tester.tap(find.text('page ${Routes.editPharmacyMedicineScreen}'));
      await tester.pumpAndSettle();

      expect(medicineRepository.fetches, fetchesBefore + 1);
    });
  });

  testWidgets('keeps the search typed through the silent reload after an add', (tester) async {
    await pumpScreen(tester);
    await tester.enterText(find.byType(TextField), 'سيفتر');
    await tester.pump();
    routeResult = true;

    await tester.tap(find.text('أضف منتج جديد'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('page ${Routes.addPharmacyMedicineScreen}'));
    await tester.pumpAndSettle();

    expect(find.text('سيفتر'), findsOneWidget);
    expect(find.byType(ProductCard), findsOneWidget);
  });
}
