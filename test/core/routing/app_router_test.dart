import 'package:daway_app/core/routing/app_router.dart';
import 'package:daway_app/core/routing/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the route to the forgot-password flow keeps its name, which the flow finds its first screen by', () {
    final route = AppRouter().generateRoute(
      const RouteSettings(name: Routes.pharmacyForgotPasswordScreen),
    );

    expect(route, isNotNull);
    expect(route!.settings.name, Routes.pharmacyForgotPasswordScreen);
  });
}
