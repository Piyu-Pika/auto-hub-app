import 'package:auto_hub_app/features/home/domain/entities/home_feed_entity.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_junk_car_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeJunkCarBanner', () {
    testWidgets('renders banner from feed data', (tester) async {
      final banner = JunkBannerEntity(
        title: 'Junk Your Car',
        subtitle: 'Get top dollar for your junk vehicle',
        imageUrl: 'assets/images/home_part_headlight.png',
        ctaUrl: '/new-junk-request',
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeJunkCarBanner(junkBanner: banner),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Junk Your Car'), findsOneWidget);
      expect(find.text('Get top dollar for your junk vehicle'), findsOneWidget);
      expect(find.text('Get Offer'), findsOneWidget);
    });

    testWidgets('returns SizedBox.shrink when banner is null', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: HomeJunkCarBanner(junkBanner: null),
            ),
          ),
        ),
      );

      expect(find.text('Junk Your Car'), findsNothing);
    });
  });
}