import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/presentation/cubit/account_type_cubit.dart';
import 'package:daway_app/features/auth/presentation/screens/account_type_screen.dart';
import 'package:daway_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:daway_app/features/onboarding/domain/usecases/get_onboarding_seen_usecase.dart';
import 'package:daway_app/features/onboarding/domain/usecases/set_onboarding_seen_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<bool> isOnboardingSeen(AccountType accountType) async => false;

  @override
  Future<void> setOnboardingSeen(AccountType accountType) async {}
}

void main() {
  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildTestableScreen(AccountTypeCubit cubit) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: BlocProvider.value(value: cubit, child: const AccountTypeScreen()),
      ),
    );
  }

  AccountTypeCubit buildCubit() {
    final repository = _FakeOnboardingRepository();
    return AccountTypeCubit(
      GetOnboardingSeenUseCase(repository),
      SetOnboardingSeenUseCase(repository),
    );
  }

  testWidgets('shows both account types and the next button', (tester) async {
    await setPhoneViewport(tester);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('مستخدم'), findsOneWidget);
    expect(find.text('صيدلي'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
  });

  testWidgets('the next button is filled with the main button colour', (tester) async {
    await setPhoneViewport(tester);
    final cubit = buildCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'التالي'));
    expect(button.style!.backgroundColor!.resolve(<WidgetState>{}), AppColors.mainTeal);
  });
}
