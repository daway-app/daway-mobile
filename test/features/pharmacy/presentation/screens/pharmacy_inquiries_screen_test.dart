import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/domain/entities/user_session.dart';
import 'package:daway_app/features/auth/domain/repositories/session_repository.dart';
import 'package:daway_app/features/pharmacy/domain/entities/inquiry.dart';
import 'package:daway_app/features/pharmacy/domain/repositories/pharmacy_inquiries_repository.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/get_pharmacy_inquiries_usecase.dart';
import 'package:daway_app/features/pharmacy/domain/usecases/update_inquiry_status_usecase.dart';
import 'package:daway_app/features/pharmacy/presentation/cubit/pharmacy_inquiries_cubit.dart';
import 'package:daway_app/features/pharmacy/presentation/screens/pharmacy_inquiries_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

final _newInquiry = Inquiry(
  id: 1,
  message: 'هل يتوفر دواء الضغط؟',
  status: InquiryStatus.newInquiry,
  createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  patientName: 'أحمد الحربي',
  medicineName: 'Panadol 500mg',
);

class _FakePharmacyInquiriesRepository implements PharmacyInquiriesRepository {
  int? lastUpdatedId;
  InquiryStatus? lastUpdatedStatus;

  @override
  Future<ApiResult<InquiriesOverview>> getInquiries({
    required String token,
  }) async {
    return Success(
      InquiriesOverview(
        inquiries: [_newInquiry],
        newCount: 1,
        answeredCount: 18,
        closedCount: 42,
      ),
    );
  }

  @override
  Future<ApiResult<void>> updateInquiryStatus({
    required String token,
    required int inquiryId,
    required InquiryStatus status,
  }) async {
    lastUpdatedId = inquiryId;
    lastUpdatedStatus = status;
    return const Success(null);
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

  late _FakePharmacyInquiriesRepository repository;

  Widget buildTestableScreen() {
    repository = _FakePharmacyInquiriesRepository();
    final sessionRepository = _FakeSessionRepository();
    final cubit = PharmacyInquiriesCubit(
      GetPharmacyInquiriesUseCase(repository, sessionRepository),
      UpdateInquiryStatusUseCase(repository, sessionRepository),
    );
    addTearDown(cubit.close);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const PharmacyInquiriesScreen(),
        ),
      ),
    );
  }

  testWidgets('shows the stat counts and the inquiry card content', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget); // newCount
    expect(find.text('18'), findsOneWidget); // answeredCount
    expect(find.text('42'), findsOneWidget); // closedCount
    expect(find.text('هل يتوفر دواء الضغط؟'), findsOneWidget);
    expect(find.text('أحمد الحربي'), findsOneWidget);
    expect(find.text('Panadol 500mg'), findsOneWidget);
  });

  testWidgets('tapping "تم الرد" on a new inquiry marks it answered', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    // "تم الرد" also appears as a stat-card label and a filter chip — only
    // the card's action button is an ElevatedButton.
    await tester.tap(find.widgetWithText(ElevatedButton, 'تم الرد'));
    await tester.pumpAndSettle();

    expect(repository.lastUpdatedId, 1);
    expect(repository.lastUpdatedStatus, InquiryStatus.answered);
  });

  testWidgets('tapping the "جديدة" filter chip narrows the list', (
    tester,
  ) async {
    await setPhoneViewport(tester);

    await tester.pumpWidget(buildTestableScreen());
    await tester.pumpAndSettle();

    // "جديدة" appears both as a stat-card label and a filter chip — the
    // filter chip is the tappable one, found via its distinct widget type.
    final chip = find.ancestor(
      of: find.text('جديدة'),
      matching: find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == 'AppFilterChip',
      ),
    );
    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(find.text('هل يتوفر دواء الضغط؟'), findsOneWidget);
  });
}
