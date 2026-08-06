import 'package:daway_app/features/auth/domain/entities/account_type.dart';
import 'package:daway_app/features/auth/presentation/cubit/account_type_cubit.dart';
import 'package:daway_app/features/auth/presentation/screens/account_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableScreen(AccountTypeCubit cubit) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const AccountTypeScreen(),
        ),
      ),
    );
  }

  Future<void> setPhoneViewport(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('shows both account type options', (tester) async {
    await setPhoneViewport(tester);
    final cubit = AccountTypeCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    expect(find.text('حساب مريض'), findsOneWidget);
    expect(find.text('حساب صيدلية'), findsOneWidget);
  });

  testWidgets('tapping the pharmacy option updates the cubit state', (tester) async {
    await setPhoneViewport(tester);
    final cubit = AccountTypeCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildTestableScreen(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.text('حساب صيدلية'));
    await tester.pumpAndSettle();

    expect(cubit.state, AccountType.pharmacy);
  });
}
