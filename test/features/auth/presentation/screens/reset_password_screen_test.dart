import 'package:daway_app/core/erroring/failure.dart';
import 'package:daway_app/core/helpers/api_result.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:daway_app/core/theming/app_colors.dart';
import 'package:daway_app/core/widgets/app_custom_button.dart';
import 'package:daway_app/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:daway_app/features/auth/presentation/cubit/password_reset_state.dart';
import 'package:daway_app/features/auth/presentation/screens/password_updated_screen.dart';
import 'package:daway_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';
import '../../../../helpers/fake_password_reset_repository.dart';

void main() {
  late FakePasswordResetRepository repository;
  late PasswordResetCubit cubit;

  const phone = '0591234529';

  setUp(() async {
    repository = FakePasswordResetRepository();
    cubit = repository.newCubit();
    // The screen is reached with the code accepted.
    await cubit.sendCode(phone);
    await cubit.verifyCode('123456');
    repository.calls.clear();
  });

  tearDown(() => cubit.close());

  Future<void> pumpScreen(WidgetTester tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(body: Text('الدخول')),
        ),
        home: BlocProvider.value(value: cubit, child: const ResetPasswordScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder passwordField() => find.byType(TextField).first;
  Finder confirmationField() => find.byType(TextField).last;

  Future<void> submit(WidgetTester tester, String password, String confirmation) async {
    await tester.enterText(passwordField(), password);
    await tester.enterText(confirmationField(), confirmation);
    await tester.tap(find.text('تعيين كلمة المرور'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }

  testWidgets('has the title, the line under it, two password fields and the button', (tester) async {
    await pumpScreen(tester);

    expect(find.text('إعادة تعيين كلمة المرور'), findsOneWidget);
    expect(find.text('أنشئ كلمة مرور جديدة لحماية حسابك.'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
    expect(find.text('تأكيد كلمة المرور'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('تعيين كلمة المرور'), findsOneWidget);
  });

  testWidgets('lays out like the design: two 56 fields, the button 24 under the last', (tester) async {
    await pumpScreen(tester);

    final first = tester.getRect(passwordField());
    final second = tester.getRect(confirmationField());
    final button = tester.getRect(find.byType(AppCustomButton));

    expect(first.size, const Size(392, 56));
    expect(second.size, const Size(392, 56));
    expect(button.size, const Size(392, 56));
    // 6 to the label, 22 above it: 28 from the first field's bottom to the label
    // of the second, and its own 24-tall line with a 5 gap below.
    expect(second.top, greaterThan(first.bottom));
    expect(button.top - second.bottom, 24);
  });

  testWidgets('the button label is Bold 16 in white', (tester) async {
    await pumpScreen(tester);

    final style = tester.widget<Text>(find.text('تعيين كلمة المرور')).style!;

    expect(style.fontSize, 16);
    expect(style.fontWeight, FontWeight.w700);
    expect(style.color, Colors.white);
  });

  testWidgets('both passwords are hidden until their own eye is pressed', (tester) async {
    await pumpScreen(tester);
    expect(tester.widget<TextField>(passwordField()).obscureText, isTrue);
    expect(tester.widget<TextField>(confirmationField()).obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
    await tester.pump();

    expect(tester.widget<TextField>(passwordField()).obscureText, isFalse);
    expect(tester.widget<TextField>(confirmationField()).obscureText, isTrue);
  });

  testWidgets('a short password is answered under the fields, which turn red', (tester) async {
    await pumpScreen(tester);

    await submit(tester, 'short', 'short');

    expect(find.text('كلمة المرور يجب أن تكون 8 أحرف على الأقل'), findsOneWidget);
    for (final finder in [passwordField(), confirmationField()]) {
      final border = tester.widget<TextField>(finder).decoration!.enabledBorder! as OutlineInputBorder;
      expect(border.borderSide.color, AppColors.authError);
    }
    expect(repository.calls, isEmpty);
    expect(find.byType(PasswordUpdatedScreen), findsNothing);
  });

  testWidgets('two passwords that differ are answered under the fields', (tester) async {
    await pumpScreen(tester);

    await submit(tester, 'new-secret-1', 'new-secret-2');

    expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
    expect(repository.calls, isEmpty);
  });

  testWidgets('a backend failure is answered under the fields', (tester) async {
    repository.resetResult = const ApiError(ApiFailure(message: 'انتهت صلاحية الطلب'));
    await pumpScreen(tester);

    await submit(tester, 'new-secret-1', 'new-secret-1');

    expect(find.text('انتهت صلاحية الطلب'), findsOneWidget);
    expect(find.byType(PasswordUpdatedScreen), findsNothing);
  });

  testWidgets('with the backend not there yet, "قريباً" comes up', (tester) async {
    repository.resetResult = const ApiError(ComingSoonFailure());
    await pumpScreen(tester);

    await submit(tester, 'new-secret-1', 'new-secret-1');

    expect(find.text('قريباً'), findsOneWidget);
    expect(find.byType(PasswordUpdatedScreen), findsNothing);
  });

  testWidgets('matching passwords are set, and the confirmation takes over the screen', (tester) async {
    await pumpScreen(tester);

    await submit(tester, 'new-secret-1', 'new-secret-1');

    expect(repository.calls, ['reset $phone proof-1 new-secret-1']);
    expect(find.byType(PasswordUpdatedScreen), findsOneWidget);
    expect(find.byType(ResetPasswordScreen), findsNothing);
    expect(cubit.state.step, PasswordResetStep.done);
  });

  testWidgets('going back returns the flow to the code step', (tester) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(value: cubit, child: const ResetPasswordScreen()),
                ),
              ),
              child: const Text('الرمز'),
            ),
          ),
        ),
      ),
    );
    final semantics = tester.ensureSemantics();
    await tester.tap(find.text('الرمز'));
    await tester.pumpAndSettle();
    expect(cubit.state.step, PasswordResetStep.newPassword);

    await tester.tap(find.bySemanticsLabel('رجوع'));
    await tester.pumpAndSettle();

    expect(find.byType(ResetPasswordScreen), findsNothing);
    expect(cubit.state.step, PasswordResetStep.code);
    semantics.dispose();
  });

  testWidgets('the confirmation leaves only what the flow was opened from under it', (tester) async {
    await setDesignViewport(tester);
    // As in the app: a screen under the login, which has no name; then the
    // forgot-password screen, which has one, and the rest of the flow.
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Navigator(
          key: navigatorKey,
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('الصفحة الأولى')),
          ),
        ),
      ),
    );
    final navigator = navigatorKey.currentState!;
    navigator.push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('الدخول'))));
    navigator.push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: Routes.pharmacyForgotPasswordScreen),
        builder: (_) => const Scaffold(body: Text('نسيت')),
      ),
    );
    navigator.push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('الرمز'))));
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => BlocProvider.value(value: cubit, child: const ResetPasswordScreen())),
    );
    await tester.pumpAndSettle();

    await submit(tester, 'new-secret-1', 'new-secret-1');
    expect(find.byType(PasswordUpdatedScreen), findsOneWidget);
    // The three screens of the flow are gone, not just covered.
    expect(find.text('نسيت', skipOffstage: false), findsNothing);
    expect(find.text('الرمز', skipOffstage: false), findsNothing);
    expect(find.byType(ResetPasswordScreen, skipOffstage: false), findsNothing);
    expect(find.text('الدخول', skipOffstage: false), findsOneWidget);

    // Two seconds later it is the login that is showing, and nothing above it.
    await tester.pump(PasswordUpdatedScreen.displayTime);
    await tester.pumpAndSettle();
    expect(find.text('الدخول'), findsOneWidget);
    expect(find.text('الصفحة الأولى', skipOffstage: false), findsOneWidget);
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('الصفحة الأولى'), findsOneWidget);
    expect(navigator.canPop(), isFalse);
  });
}
