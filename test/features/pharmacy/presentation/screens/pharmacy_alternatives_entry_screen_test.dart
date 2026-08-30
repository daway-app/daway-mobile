import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/alternatives_overview.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine_catalog_item.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_alternatives_repository.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_medicine_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_medicine_ids_with_alternative_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_medicines_with_alternative_status_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_medicines_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_alternatives_medicines_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_alternatives_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _available = Medicine(
  id: 1,
  medicineId: 11,
  name: 'Panadol Extra',
  price: 10,
  quantity: 50,
  isAvailable: true,
);
const _low = Medicine(
  id: 2,
  medicineId: 12,
  name: 'Augmentin',
  activeIngredient: 'Amoxicillin',
  price: 10,
  quantity: 5,
  isAvailable: true,
);
const _outOfStock = Medicine(
  id: 3,
  medicineId: 13,
  name: 'Bandal',
  price: 10,
  quantity: 0,
  isAvailable: true,
);
const _lowNoAlternative = Medicine(
  id: 4,
  medicineId: 14,
  name: 'Moxclav',
  price: 10,
  quantity: 3,
  isAvailable: true,
);

class _FakeMedicineRepository implements PharmacyMedicineRepository {
  int callCount = 0;
  ApiResult<List<Medicine>> getResult = const Success([
    _available,
    _low,
    _outOfStock,
    _lowNoAlternative,
  ]);

  @override
  Future<ApiResult<List<Medicine>>> getMedicines({
    required String token,
  }) async {
    callCount++;
    return getResult;
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
  }) async => throw UnimplementedError();

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
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<void>> deleteMedicine({
    required String token,
    required int pharmacyMedicineId,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<void>> updateMedicine({
    required String token,
    required int pharmacyMedicineId,
    required int medicineId,
    required double price,
    required int quantity,
    required bool isAvailable,
    required String tradeName,
    String? tradeNameAr,
    String? activeIngredient,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<List<MedicineCatalogItem>>> searchCatalog({
    required String token,
    required String query,
  }) async => throw UnimplementedError();
}

class _FakeAlternativesRepository implements PharmacyAlternativesRepository {
  @override
  Future<ApiResult<Set<int>>> getBaseMedicineIdsWithAlternatives({
    required String token,
  }) async => Success({_low.id});

  @override
  Future<ApiResult<AlternativesOverview>> getAlternativesOverview({
    required String token,
    required Medicine baseMedicine,
    required List<Medicine> allMedicines,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<void>> selectAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<void>> removeAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async => throw UnimplementedError();
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession = const UserSession(
    accountType: AccountType.pharmacy,
    token: 'tok-1',
  );

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
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  late _FakeMedicineRepository medicineRepository;

  Widget buildTestableScreen() {
    medicineRepository = _FakeMedicineRepository();
    final alternativesRepository = _FakeAlternativesRepository();
    final sessionRepository = _FakeSessionRepository();
    final cubit = PharmacyAlternativesMedicinesCubit(
      GetMedicinesWithAlternativeStatusUseCase(
        GetPharmacyMedicinesUseCase(medicineRepository, sessionRepository),
        GetMedicineIdsWithAlternativeUseCase(
          alternativesRepository,
          sessionRepository,
        ),
      ),
    );
    addTearDown(cubit.close);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const PharmacyAlternativesEntryScreen(),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == Routes.pharmacyAlternativesScreen) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('back'),
                  ),
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  testWidgets(
    'shows every medicine, not just the ones needing an alternative',
    (tester) async {
      await setPhoneViewport(tester);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('Panadol Extra'), findsOneWidget);
      expect(find.text('Augmentin'), findsOneWidget);
      expect(find.text('Bandal'), findsOneWidget);
    },
  );

  testWidgets(
    'the summary stat cards reflect needing-alternative and already-handled counts, not the full medicine count',
    (tester) async {
      await setPhoneViewport(tester);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // _low already has an alternative (1 "بدائل محددة"); _outOfStock and
      // _lowNoAlternative still need one (2 "أدوية تحتاج بديلاً") — out of 4
      // medicines total, so neither stat is just echoing the full count.
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('بديل محدد'), findsOneWidget);
    },
  );

  testWidgets('typing in the search box narrows the list', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'no such medicine');
    await tester.pumpAndSettle();

    expect(find.text('Panadol Extra'), findsNothing);
    expect(find.text('لا توجد نتائج مطابقة للبحث'), findsOneWidget);
  });

  testWidgets(
    'tapping a medicine navigates to the alternatives screen, then reloads the list on return',
    (tester) async {
      await setPhoneViewport(tester);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();
      expect(medicineRepository.callCount, 1);

      await tester.tap(find.text('Panadol Extra'));
      await tester.pumpAndSettle();
      expect(find.text('back'), findsOneWidget);

      await tester.tap(find.text('back'));
      await tester.pumpAndSettle();

      expect(find.text('Panadol Extra'), findsOneWidget);
      expect(medicineRepository.callCount, 2);
    },
  );
}
