import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/widgets/physical_pixel_box.dart';

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
  });
}
