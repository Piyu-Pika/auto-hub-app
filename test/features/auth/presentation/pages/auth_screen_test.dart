import 'package:auto_hub_app/core/router/app_router.dart';
import 'package:auto_hub_app/features/auth/presentation/pages/auth_screen.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    dotenv.loadFromString(envString: 'BASE_URL=https://api.autohubexpress.us');
    configureDependencies();
  });

  testWidgets('appRouter navigates to /login and renders AuthScreen', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 800),
        builder: (context, child) => MaterialApp.router(
          routerConfig: appRouter,
        ),
      ),
    );

    appRouter.go('/login');
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Welcome back 👋'), findsOneWidget);
  });
}
