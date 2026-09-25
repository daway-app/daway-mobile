import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/favorite_medicine.dart';
import 'package:daway_app/features/patient/domain/repositories/favorites_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_favorite_medicines_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/favorite_medicines_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_favorites_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFavoritesRepository implements FavoritesRepository {
  ApiResult<List<FavoriteMedicine>> result = const Success([]);

  @override
  Future<ApiResult<List<FavoriteMedicine>>> getFavoriteMedicines({required String token}) async =>
      result;
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
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildTestableScreen(
    _FakeFavoritesRepository repository, {
    List<String>? visitedRoutes,
  }) {
    final cubit = FavoriteMedicinesCubit(
      GetFavoriteMedicinesUseCase(repository, _FakeSessionRepository()),
    );
    addTearDown(cubit.close);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: (settings) {
          visitedRoutes?.add(settings.name ?? '');
          return MaterialPageRoute(builder: (_) => const Scaffold(body: SizedBox.shrink()));
        },
        home: BlocProvider.value(
          value: cubit,
          child: const PatientFavoritesScreen(),
        ),
      ),
    );
  }

  testWidgets('shows the empty state when there are no saved medicines', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen(_FakeFavoritesRepository()));
    await tester.pumpAndSettle();

    expect(find.text('الأدوية المحفوظة'), findsOneWidget);
    expect(find.text('لا يوجد منتجات محفوظة'), findsOneWidget);
    expect(find.text('تصفح المنتجات'), findsOneWidget);
  });

  testWidgets('tapping "تصفح المنتجات" navigates to all-categories', (tester) async {
    await setPhoneViewport(tester);
    final visitedRoutes = <String>[];

    await tester.pumpWidget(
      buildTestableScreen(_FakeFavoritesRepository(), visitedRoutes: visitedRoutes),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('تصفح المنتجات'));
    await tester.pumpAndSettle();

    expect(visitedRoutes, contains(Routes.allCategoriesScreen));
  });

  testWidgets('shows a card for each saved medicine', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeFavoritesRepository();
    repository.result = const Success([
      FavoriteMedicine(
        medicineId: 1,
        tradeName: 'Panadol',
        isAvailable: true,
        pharmaciesCount: 3,
        minPrice: 12,
      ),
      FavoriteMedicine(
        medicineId: 2,
        tradeName: 'Advil',
        isAvailable: true,
        pharmaciesCount: 5,
        minPrice: 10,
      ),
    ]);

    await tester.pumpWidget(buildTestableScreen(repository));
    await tester.pumpAndSettle();

    expect(find.text('Panadol'), findsOneWidget);
    expect(find.text('Advil'), findsOneWidget);
    expect(find.text('لا يوجد منتجات محفوظة'), findsNothing);
  });

  testWidgets('shows an error with a working retry button on failure', (tester) async {
    await setPhoneViewport(tester);
    final repository = _FakeFavoritesRepository();
    repository.result = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await tester.pumpWidget(buildTestableScreen(repository));
    await tester.pumpAndSettle();
    expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);

    repository.result = const Success([
      FavoriteMedicine(medicineId: 1, tradeName: 'Panadol', isAvailable: true, pharmaciesCount: 1),
    ]);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.text('Panadol'), findsOneWidget);
  });
}
