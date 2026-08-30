import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/alternatives_overview.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine.dart';
import 'package:daway_app/features/pharmacy/domain/entities/medicine_catalog_item.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_alternatives_repository.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_medicine_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_alternatives_overview_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_medicines_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/remove_alternative_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/select_alternative_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_alternatives_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_alternatives_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _baseMedicine = Medicine(
  id: 14,
  medicineId: 17,
  name: 'Augmentin',
  activeIngredient: 'Amoxicillin + Clavulanic Acid',
  price: 30,
  quantity: 0,
  isAvailable: true,
  isOutOfStock: true,
);
const _candidate = Medicine(
  id: 16,
  medicineId: 19,
  name: 'Moxclav',
  activeIngredient: 'Amoxicillin + Clavulanic Acid',
  price: 22,
  quantity: 86,
  isAvailable: true,
);

class _FakeRepository implements PharmacyAlternativesRepository {
  Set<int> selectedIds;
  int selectCallCount = 0;
  int removeCallCount = 0;

  _FakeRepository({this.selectedIds = const {}});

  @override
  Future<ApiResult<AlternativesOverview>> getAlternativesOverview({
    required String token,
    required Medicine baseMedicine,
    required List<Medicine> allMedicines,
  }) async {
    return Success(
      AlternativesOverview(
        baseMedicine: baseMedicine,
        candidates: const [_candidate],
        selectedAlternativeIds: selectedIds,
      ),
    );
  }

  @override
  Future<ApiResult<void>> selectAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async {
    selectCallCount++;
    selectedIds = {alternativeId};
    return const Success(null);
  }

  @override
  Future<ApiResult<void>> removeAlternative({
    required String token,
    required int baseMedicineId,
    required int alternativeId,
  }) async {
    removeCallCount++;
    selectedIds = {};
    return const Success(null);
  }

  @override
  Future<ApiResult<Set<int>>> getBaseMedicineIdsWithAlternatives({
    required String token,
  }) async => throw UnimplementedError();
}

class _FakeMedicineRepository implements PharmacyMedicineRepository {
  @override
  Future<ApiResult<List<Medicine>>> getMedicines({
    required String token,
  }) async => const Success([_baseMedicine, _candidate]);

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
  }) async => throw UnimplementedError();

  @override
  Future<ApiResult<List<MedicineCatalogItem>>> searchCatalog({
    required String token,
    required String query,
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

  Widget buildTestableScreen(_FakeRepository repository) {
    final sessionRepository = _FakeSessionRepository();
    final cubit = PharmacyAlternativesCubit(
      _baseMedicine,
      GetAlternativesOverviewUseCase(
        repository,
        GetPharmacyMedicinesUseCase(
          _FakeMedicineRepository(),
          sessionRepository,
        ),
        sessionRepository,
      ),
      SelectAlternativeUseCase(repository, sessionRepository),
      RemoveAlternativeUseCase(repository, sessionRepository),
    );
    addTearDown(cubit.close);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const PharmacyAlternativesScreen(),
        ),
      ),
    );
  }

  testWidgets('shows the base medicine banner and candidate list', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen(_FakeRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Augmentin'), findsOneWidget);
    expect(find.text('غير متوفر حالياً'), findsOneWidget);
    expect(find.text('Moxclav'), findsOneWidget);
    expect(find.text('اختيار البديل'), findsOneWidget);
  });

  testWidgets(
    'tapping "اختيار البديل" selects the candidate and shows it as selected',
    (tester) async {
      await setPhoneViewport(tester);
      final repository = _FakeRepository();

      await tester.pumpWidget(buildTestableScreen(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('اختيار البديل'));
      await tester.pumpAndSettle();

      expect(repository.selectCallCount, 1);
      expect(find.text('تم اختياره'), findsOneWidget);
      expect(find.text('اختيار البديل'), findsNothing);
    },
  );

  testWidgets('tapping an already-selected candidate removes it', (
    tester,
  ) async {
    await setPhoneViewport(tester);
    final repository = _FakeRepository(selectedIds: {_candidate.medicineId});

    await tester.pumpWidget(buildTestableScreen(repository));
    await tester.pumpAndSettle();

    expect(find.text('تم اختياره'), findsOneWidget);

    await tester.tap(find.text('تم اختياره'));
    await tester.pumpAndSettle();

    expect(repository.removeCallCount, 1);
    expect(find.text('اختيار البديل'), findsOneWidget);
  });
}
