import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/widgets/physical_pixel_box.dart';

void main() {
  group('PhysicalPixelBox', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        const PhysicalPixelBox(
          child: SizedBox(width: 100, height: 100),
        ),
      );
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('creates border with physical pixel width', (tester) async {
      await tester.pumpWidget(
        const PhysicalPixelBox(
          dpr: 3.0,
          child: SizedBox(width: 100, height: 100),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container));
      final border = container.decoration as BoxDecoration;
      expect(border.border, isNotNull);
    });

    testWidgets('dpr=2: width=1 produces 0.5 logical border', (tester) async {
      await tester.pumpWidget(
        const PhysicalPixelBox(
          dpr: 2.0,
          width: 1,
          child: SizedBox(width: 100, height: 100),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container));
      final border = (container.decoration as BoxDecoration).border!;
      // 1 / 2 = 0.5
      expect(border.top.width, closeTo(0.5, 0.001));
    });

    testWidgets('dpr=3: width=1 produces ~0.333 logical border', (tester) async {
      await tester.pumpWidget(
        const PhysicalPixelBox(
          dpr: 3.0,
          width: 1,
          child: SizedBox(width: 100, height: 100),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container));
      final border = (container.decoration as BoxDecoration).border!;
      expect(border.top.width, closeTo(1.0 / 3.0, 0.001));
    });

    testWidgets('custom color is applied to border', (tester) async {
      await tester.pumpWidget(
        const PhysicalPixelBox(
          dpr: 3.0,
          color: Color(0xFFFF0000),
          child: SizedBox(width: 100, height: 100),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container));
      final border = (container.decoration as BoxDecoration).border!;
      expect(border.top.color, const Color(0xFFFF0000));
    });

    testWidgets('default color is grey-ish (0xFFE0E0E0)', (tester) async {
      await tester.pumpWidget(
        const PhysicalPixelBox(
          dpr: 3.0,
          child: SizedBox(width: 100, height: 100),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container));
      final border = (container.decoration as BoxDecoration).border!;
      expect(border.top.color, const Color(0xFFE0E0E0));
    });

    testWidgets('higher dpr → thinner logical border for same physical width', (tester) async {
      await tester.pumpWidget(
        const PhysicalPixelBox(
          dpr: 2.0,
          width: 1,
          child: SizedBox(width: 100, height: 100),
        ),
      );
      final c2 = tester.widget<Container>(find.byType(Container));
      final w2 = (c2.decoration as BoxDecoration).border!.top.width;

      await tester.pumpWidget(
        const PhysicalPixelBox(
          dpr: 4.0,
          width: 1,
          child: SizedBox(width: 100, height: 100),
        ),
      );
      final c4 = tester.widget<Container>(find.byType(Container));
      final w4 = (c4.decoration as BoxDecoration).border!.top.width;

      expect(w2, greaterThan(w4));
    });

    testWidgets('dpr=0: border width is 0 (not infinity/NaN)', (tester) async {
      // TDD: dpr=0 produces width/0 = infinity. Should fall back to 0 (safe default).
      await tester.pumpWidget(
        const PhysicalPixelBox(
          dpr: 0.0,
          width: 1,
          child: SizedBox(width: 100, height: 100),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container));
      final border = (container.decoration as BoxDecoration).border!;
      expect(border.top.width, 0.0);
      expect(border.top.width.isFinite, isTrue);
    });
  });
}
