import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/widgets/star_rating.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/rating.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_ratings_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_ratings_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_ratings_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_ratings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

final _rating = Rating(
  id: 1,
  stars: 5,
  comment: 'خدمة ممتازة وسريعة جدًا',
  createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  patientName: 'أحمد العتيبي',
);

class _FakePharmacyRatingsRepository implements PharmacyRatingsRepository {
  double averageRating = 4.7;

  @override
  Future<ApiResult<RatingsOverview>> getRatings({required String token}) async {
    return Success(
      RatingsOverview(
        ratings: [_rating],
        totalCount: 128,
        averageRating: averageRating,
        starCounts: const {5: 96, 4: 21, 3: 7, 2: 3, 1: 1},
      ),
    );
  }
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

  Widget buildTestableScreen({_FakePharmacyRatingsRepository? repositoryOverride}) {
    final repository = repositoryOverride ?? _FakePharmacyRatingsRepository();
    final sessionRepository = _FakeSessionRepository();
    final cubit = PharmacyRatingsCubit(
      GetPharmacyRatingsUseCase(repository, sessionRepository),
    );
    addTearDown(cubit.close);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: BlocProvider.value(value: cubit, child: const PharmacyRatingsScreen()),
      ),
    );
  }

  testWidgets('shows the average, total count, and a review card', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('4.7'), findsOneWidget);
    expect(find.text('128 تقييمًا'), findsOneWidget);
    expect(find.text('أحمد العتيبي'), findsOneWidget);
    expect(find.text('خدمة ممتازة وسريعة جدًا'), findsOneWidget);
  });

  testWidgets('shows the star breakdown counts', (tester) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('96'), findsOneWidget);
    expect(find.text('21'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets(
    'the displayed average text and the star icons agree at a rounding boundary',
    (tester) async {
      await setPhoneViewport(tester);
      final repository = _FakePharmacyRatingsRepository()..averageRating = 4.97;

      await tester.pumpWidget(buildTestableScreen(repositoryOverride: repository));
      await tester.pumpAndSettle();

      expect(find.text('5.0'), findsOneWidget);
      final starRatings = tester
          .widgetList<StarRating>(find.byType(StarRating))
          .toList();
      // The summary header's StarRating (the review card's is a separate,
      // unrelated instance showing its own whole-number rating).
      expect(starRatings.first.rating, 5.0);
    },
  );
}
