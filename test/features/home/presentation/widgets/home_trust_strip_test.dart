import 'package:auto_hub_app/features/home/domain/entities/home_feed_entity.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_trust_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeTrustStrip', () {
    testWidgets('renders trust items from feed data', (tester) async {
      final items = [
        TrustStripItemEntity(icon: 'assets/icons/ic_shield.svg', label: 'Trusted'),
        TrustStripItemEntity(icon: 'assets/icons/ic_verified_yards.svg', label: 'Verified'),
        TrustStripItemEntity(icon: 'assets/icons/ic_top_rated.svg', label: 'Top Rated'),
      ];

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: HomeTrustStrip(trustItems: items),
            ),
          ),
        ),
      );

      expect(find.text('Trusted'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Top Rated'), findsOneWidget);
    });

    testWidgets('returns SizedBox.shrink when trustItems is null', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: HomeTrustStrip(trustItems: null),
            ),
          ),
        ),
      );

      expect(find.text('Trusted'), findsNothing);
    });

    testWidgets('returns SizedBox.shrink when trustItems is empty', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: HomeTrustStrip(trustItems: const []),
            ),
          ),
        ),
      );

      expect(find.text('Trusted'), findsNothing);
    });
  });
}