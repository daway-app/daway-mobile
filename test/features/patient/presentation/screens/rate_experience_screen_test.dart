import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/widgets/star_rating.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/patient/domain/repositories/patient_ratings_repository.dart';
import 'package:daway_app/features/patient/domain/usecases/submit_pharmacy_rating_usecase.dart';
import 'package:daway_app/features/patient/presentation/cubit/rate_experience_cubit.dart';
import 'package:daway_app/features/patient/presentation/screens/rate_experience_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _FakePatientRatingsRepository implements PatientRatingsRepository {
  ApiResult<void> result = const Success(null);
  int? lastStars;

  @override
  Future<ApiResult<void>> submitPharmacyRating({
    required String token,
    required int pharmacyId,
    required int stars,
    String? comment,
  }) async {
    lastStars = stars;
    return result;
  }
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
    tester.view.physicalSize = const Size(440, 956);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // Registered directly via getIt (bypassing dependency_injection.dart's
  // wiring) the same way medicine_detail_screen_test.dart does.
  final getIt = GetIt.instance;
  late _FakePatientRatingsRepository repository;

  setUp(() {
    repository = _FakePatientRatingsRepository();
    final sessionRepository = _FakeSessionRepository();
    getIt.registerFactoryParam<RateExperienceCubit, int, void>(
      (pharmacyId, _) => RateExperienceCubit(
        pharmacyId,
        SubmitPharmacyRatingUseCase(repository, sessionRepository),
      ),
    );
  });

  tearDown(() => getIt.reset());

  Widget buildTestableScreen() {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      builder: (context, child) => MaterialApp(
        home: RateExperienceScreen(pharmacyId: 11, pharmacyName: 'صيدلية النور'),
      ),
    );
  }

  testWidgets('shows the header with the pharmacy name and both rating cards', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('قيم تجربتك معنا'), findsOneWidget);
    expect(find.textContaining('صيدلية النور'), findsOneWidget);
    expect(find.text('تقييم التطبيق'), findsOneWidget);
    expect(find.text('تقييم الصيدلية'), findsOneWidget);
    expect(find.text('اضغط على نجمة لتقييم'), findsNWidgets(2));
  });

  testWidgets('tapping the 1st star on the app card shows the "سيء" label', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    // The app-rating card is the first StarRating in the tree; its first
    // star is its first GestureDetector (the header's own back button has
    // its own GestureDetector too, so a bare `.first` over the whole tree
    // would hit that instead).
    await tester.tap(
      find
          .descendant(of: find.byType(StarRating).first, matching: find.byType(GestureDetector))
          .first,
    );
    await tester.pumpAndSettle();

    expect(find.text('سيء'), findsOneWidget);
  });

  testWidgets('submitting with nothing rated shows a validation message', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();
    await tester.tap(find.text('إرسال التقييم'));
    await tester.pumpAndSettle();

    expect(find.text('يرجى اختيار تقييم واحد على الأقل'), findsOneWidget);
  });
}
