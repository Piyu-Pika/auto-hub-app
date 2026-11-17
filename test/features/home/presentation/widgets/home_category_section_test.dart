import 'package:auto_hub_app/features/home/domain/entities/home_feed_entity.dart';
import 'package:auto_hub_app/features/home/presentation/widgets/home_category_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeCategorySection', () {
    testWidgets('renders categories from feed data', (tester) async {
      final categories = [
        HomeCategoryEntity(
          id: '1',
          name: 'Engine Parts',
          iconUrl: 'assets/icons/ic_category.svg',
          partCount: 50,
        ),
        HomeCategoryEntity(
          id: '2',
          name: 'Brake Parts',
          iconUrl: 'assets/icons/ic_category.svg',
          partCount: 30,
        ),
      ];

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeCategorySection(categories: categories),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Engine Parts'), findsOneWidget);
      expect(find.text('Brake Parts'), findsOneWidget);
    });

    testWidgets('returns SizedBox.shrink when categories is null', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: HomeCategorySection(categories: null),
            ),
          ),
        ),
      );

      expect(find.text('Engine Parts'), findsNothing);
    });

    testWidgets('returns SizedBox.shrink when categories is empty', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: HomeCategorySection(categories: const []),
            ),
          ),
        ),
      );

      expect(find.text('Engine Parts'), findsNothing);
    });
  });
}