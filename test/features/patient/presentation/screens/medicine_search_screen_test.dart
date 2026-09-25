import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/patient/domain/entities/searched_medicine.dart';
import 'package:daway_app/features/patient/domain/repositories/medicine_search_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/search_medicines_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/medicine_search_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/medicine_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _FakeMedicineSearchRepository implements MedicineSearchRepository {
  ApiResult<List<SearchedMedicine>> result = const Success([]);
  String? lastQuery;

  @override
  Future<ApiResult<List<SearchedMedicine>>> search(String query) async {
    lastQuery = query;
    return result;
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
  late _FakeMedicineSearchRepository repository;

  setUp(() {
    repository = _FakeMedicineSearchRepository();
    getIt.registerFactory<MedicineSearchCubit>(
      () => MedicineSearchCubit(SearchMedicinesUseCase(repository)),
    );
  });

  tearDown(() => getIt.reset());

  Widget buildTestableScreen() {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      // Wrapped in a Scaffold to match how the shell actually hosts this
      // tab (Scaffold(body: IndexedStack(...))) — the results grid's
      // Expanded needs that bounded height.
      builder: (context, child) => const MaterialApp(
        home: Scaffold(body: MedicineSearchScreen()),
      ),
    );
  }

  testWidgets('shows the trending searches before anything is typed', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('الأكثر بحثاً'), findsOneWidget);
    expect(find.text('بانادول'), findsOneWidget);
    expect(find.text('فيتامين C'), findsOneWidget);
  });

  testWidgets('typing a query debounces, then shows the matching results', (tester) async {
    await setPhoneViewport(tester);
    repository.result = const Success([
      SearchedMedicine(
        id: 1,
        tradeName: 'Panadol',
        isAvailable: true,
        availablePharmaciesCount: 3,
      ),
    ]);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'panadol');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(repository.lastQuery, 'panadol');
    expect(find.text('Panadol'), findsOneWidget);
    expect(find.text('متوفر في 3 صيدليات'), findsOneWidget);
    expect(find.text('الأكثر بحثاً'), findsNothing);
  });

  testWidgets('tapping a trending term searches for it directly', (tester) async {
    await setPhoneViewport(tester);
    repository.result = const Success([
      SearchedMedicine(
        id: 1,
        tradeName: 'Panadol',
        isAvailable: true,
        availablePharmaciesCount: 2,
      ),
    ]);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('بانادول'));
    await tester.pumpAndSettle();

    expect(repository.lastQuery, 'بانادول');
    expect(find.text('Panadol'), findsOneWidget);
  });

  testWidgets('shows an empty-results message when nothing matches', (tester) async {
    await setPhoneViewport(tester);
    repository.result = const Success([]);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz-no-such-drug');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('لا توجد نتائج مطابقة'), findsOneWidget);
  });
}
