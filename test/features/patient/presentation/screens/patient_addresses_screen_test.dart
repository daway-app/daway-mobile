import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/models/picked_location.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/entities/patient_address.dart';
import 'package:daway_app/features/patient/domain/entities/patient_profile.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_addresses_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_profile_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/create_patient_address_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/delete_patient_address_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_addresses_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/get_patient_profile_usecase.dart';
import 'package:daway_app/features/patient/domain/usecases/update_patient_address_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/patient_addresses_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/patient_addresses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

const _address = PatientAddress(
  id: 1,
  label: 'المنزل',
  recipientName: 'مريض تجريبي',
  phone: '0599112233',
  address: 'غزة - الرمال - مقابل فلافل السوسي',
  latitude: 31.5,
  longitude: 34.46,
  isDefault: true,
);

class _FakeAddressesRepository implements PatientAddressesRepository {

  @override
  Future<ApiResult<void>> deleteAddress({required String token, required int addressId}) async {
    lastDeletedAddressId = addressId;
    return const Success(null);
  }
  ApiResult<List<PatientAddress>> addressesResult = const Success([]);
  ApiResult<PatientAddress> createResult = const Success(_address);
  int? lastDeletedAddressId;
  String? lastCreatedLabel;
  ApiResult<PatientAddress> updateResult = const Success(_address);
  double? lastCreateLatitude;
  double? lastUpdateLatitude;
  int? lastUpdatedAddressId;

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
  }) async {
    lastCreatedLabel = label;
    lastCreateLatitude = latitude;
    if (createResult case Success(:final data)) {
      final existing = (addressesResult as Success).data;
      addressesResult = Success([...existing, data]);
    }
    return createResult;
  }

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
  }) async {
    lastUpdatedAddressId = addressId;
    lastUpdateLatitude = latitude;
    if (updateResult case Success(:final data)) {
      final existing = (addressesResult as Success).data;
      addressesResult = Success([
        for (final address in existing)
          if (address.id == addressId) data else address,
      ]);
    }
    return updateResult;
  }
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
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final getIt = GetIt.instance;
  late _FakeAddressesRepository addressesRepository;

  setUp(() {
    addressesRepository = _FakeAddressesRepository();
    final sessionRepository = _FakeSessionRepository();
    final profileRepository = _FakeProfileRepository();

    getIt.registerFactory<PatientAddressesCubit>(
      () => PatientAddressesCubit(
        GetPatientAddressesUseCase(addressesRepository, sessionRepository),
        CreatePatientAddressUseCase(addressesRepository, sessionRepository),
        UpdatePatientAddressUseCase(addressesRepository, sessionRepository),
        GetPatientProfileUseCase(profileRepository, sessionRepository),
        DeletePatientAddressUseCase(addressesRepository, sessionRepository),
      ),
    );
  });

  tearDown(() => getIt.reset());

  /// The map picker route is stubbed with a screen that pops [picked] (or
  /// nothing) as soon as it is shown, standing in for the real picker.
  Widget buildTestableScreen({
    List<String>? visitedRoutes,
    PickedLocation? picked,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        // The app theme's page background (AppTheme.lightTheme is not used
        // here: it pulls in google_fonts, which the tests keep off).
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        onGenerateRoute: (settings) {
          visitedRoutes?.add(settings.name ?? '');
          return MaterialPageRoute<PickedLocation>(
            builder: (routeContext) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(routeContext).pop(picked);
              });
              return const Scaffold(body: SizedBox.shrink());
            },
          );
        },
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: PatientAddressesScreen(),
        ),
      ),
    );
  }

  testWidgets('shows the empty state, with no address list button, when nothing is saved', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('عناويني'), findsOneWidget);
    expect(find.text('لا يوجد عناوين محفوظة'), findsOneWidget);
    expect(find.text('أضف عنوان'), findsOneWidget);
    expect(find.text('اضافة عنوان'), findsNothing); // the list's own add button
  });

  testWidgets('the page is on a white background, like the other patient screens', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    // The Scaffold paints its background with the first Material under it.
    final page = tester.widget<Material>(
      find.descendant(of: find.byType(Scaffold), matching: find.byType(Material)).first,
    );
    expect(page.color, Colors.white);
  });

  testWidgets('tapping "أضف عنوان" opens the location picker', (tester) async {
    await setPhoneViewport(tester);
    final visitedRoutes = <String>[];

    await tester.pumpWidget(buildTestableScreen(visitedRoutes: visitedRoutes));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أضف عنوان'));
    await tester.pumpAndSettle();

    expect(visitedRoutes, contains(Routes.locationPickerScreen));
  });

  testWidgets('a picked location replaces the empty state with an address card', (tester) async {
    await setPhoneViewport(tester);
    addressesRepository.createResult = const Success(_address);

    await tester.pumpWidget(
      buildTestableScreen(
        picked: const PickedLocation(
          latitude: 31.5,
          longitude: 34.46,
          address: 'غزة - الرمال - مقابل فلافل السوسي',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('أضف عنوان'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ العنوان'));
    await tester.pumpAndSettle();

    expect(find.text('لا يوجد عناوين محفوظة'), findsNothing);
    expect(find.text('المنزل'), findsOneWidget);
    expect(find.text('غزة - الرمال - مقابل فلافل السوسي'), findsOneWidget);
    expect(find.text('اضافة عنوان'), findsOneWidget);
  });

  testWidgets('a create failure shows a snackbar instead of silently doing nothing',
      (tester) async {
    await setPhoneViewport(tester);
    addressesRepository.createResult = const ApiError(NetworkFailure('تعذر الاتصال بالخادم'));

    await tester.pumpWidget(
      buildTestableScreen(
        picked: const PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('أضف عنوان'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ العنوان'));
    await tester.pumpAndSettle();

    expect(find.text('تعذر الاتصال بالخادم'), findsOneWidget);
    expect(find.text('لا يوجد عناوين محفوظة'), findsOneWidget); // still empty
  });

  testWidgets('tapping edit on an existing address updates it in place', (tester) async {
    await setPhoneViewport(tester);
    addressesRepository.addressesResult = const Success([_address]);
    addressesRepository.updateResult = const Success(
      PatientAddress(
        id: 1,
        label: 'المنزل',
        recipientName: 'مريض تجريبي',
        phone: '0599112233',
        address: 'خان يونس',
        latitude: 31.3,
        longitude: 34.3,
        isDefault: true,
      ),
    );

    await tester.pumpWidget(
      buildTestableScreen(
        picked: const PickedLocation(latitude: 31.3, longitude: 34.3, address: 'خان يونس'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('تعديل'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تغيير الموقع'));
    await tester.pumpAndSettle();

    expect(addressesRepository.lastUpdatedAddressId, 1);
    expect(find.text('خان يونس'), findsOneWidget);
  });

  testWidgets('the address type picked in the sheet is what gets saved', (tester) async {
    await setPhoneViewport(tester);
    addressesRepository.createResult = const Success(_address);

    await tester.pumpWidget(
      buildTestableScreen(
        picked: const PickedLocation(latitude: 31.5, longitude: 34.46, address: 'غزة'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('أضف عنوان'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العمل'));
    await tester.pump();
    await tester.tap(find.text('حفظ العنوان'));
    await tester.pumpAndSettle();

    expect(addressesRepository.lastCreatedLabel, 'العمل');
  });

  testWidgets('deleting an address asks first, then removes it', (tester) async {
    await setPhoneViewport(tester);
    addressesRepository.addressesResult = const Success([_address]);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    await tester.tap(find.text('تعديل'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف العنوان'));
    await tester.pumpAndSettle();

    expect(addressesRepository.lastDeletedAddressId, isNull); // not yet: needs confirming

    await tester.tap(find.text('حذف'));
    await tester.pumpAndSettle();

    expect(addressesRepository.lastDeletedAddressId, 1);
  });
}
