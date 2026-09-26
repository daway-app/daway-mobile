import 'package:daway_app/features/auth/presentation/widgets/resend_code_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/arabic_test_app.dart';

void main() {
  Future<void> pumpLink(
    WidgetTester tester, {
    required Future<bool> Function() onResend,
    bool isSending = false,
    TextStyle? textStyle,
  }) async {
    await setDesignViewport(tester);
    await tester.pumpWidget(
      buildArabicTestApp(
        home: Scaffold(
          body: Center(
            child: ResendCodeLink(onResend: onResend, isSending: isSending, textStyle: textStyle),
          ),
        ),
      ),
    );
  }

  Future<bool> yes() async => true;

  testWidgets('starts with a countdown from 30 seconds', (tester) async {
    await pumpLink(tester, onResend: yes);

    expect(find.text('إعادة الإرسال خلال 00:30'), findsOneWidget);
    expect(find.text('إعادة إرسال الرمز'), findsNothing);
  });

  testWidgets('counts down a second at a time', (tester) async {
    await pumpLink(tester, onResend: yes);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('إعادة الإرسال خلال 00:29'), findsOneWidget);

    await tester.pump(const Duration(seconds: 9));
    expect(find.text('إعادة الإرسال خلال 00:20'), findsOneWidget);
  });

  testWidgets('offers the link once the 30 seconds are up', (tester) async {
    await pumpLink(tester, onResend: yes);

    await tester.pump(const Duration(seconds: 29));
    expect(find.text('إعادة الإرسال خلال 00:01'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('إعادة إرسال الرمز'), findsOneWidget);
    expect(find.textContaining('إعادة الإرسال خلال'), findsNothing);
  });

  testWidgets('pressing the link asks for a code, and a sent one restarts the countdown', (
    tester,
  ) async {
    var asked = 0;
    await pumpLink(
      tester,
      onResend: () async {
        asked++;
        return true;
      },
    );
    await tester.pump(const Duration(seconds: 30));

    await tester.tap(find.text('إعادة إرسال الرمز'));
    await tester.pump();

    expect(asked, 1);
    expect(find.text('إعادة الإرسال خلال 00:30'), findsOneWidget);
  });

  testWidgets('a code that could not be sent leaves the link to be pressed again', (tester) async {
    var asked = 0;
    await pumpLink(
      tester,
      onResend: () async {
        asked++;
        return false;
      },
    );
    await tester.pump(const Duration(seconds: 30));

    await tester.tap(find.text('إعادة إرسال الرمز'));
    await tester.pump();
    expect(find.text('إعادة إرسال الرمز'), findsOneWidget);

    await tester.tap(find.text('إعادة إرسال الرمز'));
    await tester.pump();
    expect(asked, 2);
  });

  testWidgets('shows a spinner instead of the text while a code is being sent', (tester) async {
    await pumpLink(tester, onResend: yes, isSending: true);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('إعادة'), findsNothing);
  });

  testWidgets('takes the size of its text from the style it is given', (tester) async {
    await pumpLink(tester, onResend: yes, textStyle: const TextStyle(fontSize: 13));

    expect(tester.widget<Text>(find.text('إعادة الإرسال خلال 00:30')).style!.fontSize, 13);
  });

  testWidgets('leaves no timer running when it goes away', (tester) async {
    await pumpLink(tester, onResend: yes);

    await tester.pumpWidget(const SizedBox.shrink());

    // The framework fails a test that ends with a timer still pending.
    expect(tester.takeException(), isNull);
  });
}
