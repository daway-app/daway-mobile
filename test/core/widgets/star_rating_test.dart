import 'package:daway_app/core/widgets/star_rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // StarRating uses ScreenUtil's .sp extension internally, which throws
  // unless ScreenUtilInit has run first.
  Widget wrap(Widget child) => ScreenUtilInit(
        designSize: const Size(440, 956),
        builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
      );

  testWidgets('renders 5 stars and is not tappable without onRatingChanged', (tester) async {
    await tester.pumpWidget(wrap(const StarRating(rating: 3)));

    expect(find.byType(Icon), findsNWidgets(5));
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('tapping the 4th star reports 4', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      wrap(StarRating(rating: 0, onRatingChanged: (stars) => tapped = stars)),
    );

    // Pinned left-to-right (textDirection: ltr) regardless of locale, so the
    // 4th GestureDetector in tree order is the 4th star.
    await tester.tap(find.byType(GestureDetector).at(3));

    expect(tapped, 4);
  });
}
