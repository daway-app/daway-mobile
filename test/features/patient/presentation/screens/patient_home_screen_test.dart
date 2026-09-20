import 'dart:io';

import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/patient_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/pharmacy_auth_result.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:daway_app/features/auth/presentation/cubit/logout_cubit.dart';
import 'package:daway_app/features/patient/domain/entities/category.dart';
import 'package:daway_app/features/patient/domain/entities/category_medicines_result.dart';
import 'package:daway_app/features/patient/domain/entities/patient_profile.dart';
import 'package:daway_app/features/patient/domain/repositories/avatar_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/category_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_profile_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/get_categories_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_profile_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/update_patient_profile_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/upload_avatar_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/categories_cubit.dart';
import 'package:daway_app/features/patient/presentation/cubit/patient_profile_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

const _profile = PatientProfile(
  name: 'فارس حميد',
  phone: '0599123456',
  latitude: 31.5017,
  longitude: 34.4668,
  address: 'غزة الرمال',
);

const _categories = [
  Category(id: 1, nameAr: 'أدوية', slug: 'medicines'),
  Category(id: 2, nameAr: 'العناية بالأسنان', slug: 'dental-care'),
];

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<String?>> sendOtp({required String phone}) async => const Success(null);

  @override
  Future<ApiResult<PatientAuthResult>> verifyOtp({
    required String phone,
    required String otp,
    String? name,
    String? birthDate,
    double? latitude,
    double? longitude,
    bool? notificationsEnabled,
  }) async => const Success(PatientAuthResult(token: 'tok', isNewAccount: false));

  @override
  Future<ApiResult<PharmacyAuthResult>> pharmacyLogin({
    required String pharmacyId,
    required String password,
  }) async => const Success(PharmacyAuthResult(token: 'tok'));

  @override
  Future<ApiResult<void>> registerPharmacy({
    required String pharmacyName,
    required String phone,
    required String region,
    required String password,
  }) async => const Success(null);

  @override
  Future<ApiResult<void>> logout({required String token}) async => const Success(null);
}

class _FakeSessionRepository implements SessionRepository {
  UserSession? savedSession = const UserSession(accountType: AccountType.patient, token: 'tok-1');

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

class _FakePatientProfileRepository implements PatientProfileRepository {
  @override
  Future<ApiResult<PatientProfile>> getProfile({required String token}) async =>
      const Success(_profile);

  @override
  Future<ApiResult<void>> updateProfile({
    required String token,
    required PatientProfile profile,
  }) async => const Success(null);
}

class _FakeAvatarRepository implements AvatarRepository {
  @override
  Future<ApiResult<String>> uploadAvatar(File imageFile) async => const Success('');
}

class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<ApiResult<List<Category>>> getCategories() async => const Success(_categories);

  @override
  Future<ApiResult<CategoryMedicinesResult>> getCategoryMedicines({
    required String categorySlug,
    String? subcategorySlug,
    String? dosageForm,
    String? query,
    int page = 1,
    int perPage = 20,
  }) async =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<String>>> getDosageForms() async => throw UnimplementedError();
}

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final getIt = GetIt.instance;

  setUp(() {
    final profileSessionRepository = _FakeSessionRepository();
    final profileRepository = _FakePatientProfileRepository();
    getIt.registerFactory<PatientProfileCubit>(
      () => PatientProfileCubit(
        GetPatientProfileUseCase(profileRepository, profileSessionRepository),
        UpdatePatientProfileUseCase(profileRepository, profileSessionRepository),
        UploadAvatarUseCase(_FakeAvatarRepository()),
      ),
    );
    getIt.registerFactory<CategoriesCubit>(
      () => CategoriesCubit(GetCategoriesUseCase(_FakeCategoryRepository())),
    );
  });

  tearDown(() => getIt.reset());

  Widget buildTestableScreen(LogoutCubit cubit, {List<String>? visitedRoutes}) {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (context, child) => MaterialApp(
        onGenerateRoute: (settings) {
          visitedRoutes?.add(settings.name ?? '');
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: SizedBox.shrink()),
          );
        },
        home: BlocProvider.value(
          value: cubit,
          child: const PatientHomeScreen(),
        ),
      ),
    );
  }

  testWidgets('shows the greeting with the patient name and the loaded categories',
      (tester) async {
    await setPhoneViewport(tester);
    final cubit = LogoutCubit(LogoutUseCase(_FakeAuthRepository(), _FakeSessionRepository()));
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    expect(find.textContaining('فارس حميد'), findsOneWidget);
    expect(find.text('أدوية'), findsOneWidget);
    expect(find.text('العناية بالأسنان'), findsOneWidget);
  });

  testWidgets('navigates to account-type screen once LogoutCubit reports logged out',
      (tester) async {
    await setPhoneViewport(tester);
    final cubit = LogoutCubit(LogoutUseCase(_FakeAuthRepository(), _FakeSessionRepository()));
    addTearDown(cubit.close);

    final visitedRoutes = <String>[];
    await tester.pumpWidget(buildTestableScreen(cubit, visitedRoutes: visitedRoutes));
    await tester.pumpAndSettle();

    await cubit.logout();
    await tester.pumpAndSettle();

    expect(cubit.state.isLoggedOut, isTrue);
    expect(visitedRoutes, contains(Routes.accountTypeScreen));
  });
}
