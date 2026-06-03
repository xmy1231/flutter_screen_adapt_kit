import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/widgets/unscale_box.dart';

void main() {
  group('UnscaleBox', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        const UnscaleBox(
          child: SizedBox(width: 100, height: 100),
        ),
      );
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('applies inverse scale transform', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const UnscaleBox(
            dpr: 2.0,
            designWidth: 375,
            child: Text('Hello'),
          ),
        ),
      );
      final transform = tester.widget<Transform>(find.byType(Transform));
      expect(transform.transform.getMaxScaleOnAxis(), closeTo(0.5, 0.01));
    });

    testWidgets('UnscaleMode.context uses MediaQuery textScaleFactor', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(textScaleFactor: 2.0),
            child: const UnscaleBox(
              dpr: 2.0,
              designWidth: 375,
              mode: UnscaleMode.context,
              child: Text('Hello'),
            ),
          ),
        ),
      );
      final transform = tester.widget<Transform>(find.byType(Transform));
      expect(transform.transform.getMaxScaleOnAxis(), closeTo(0.5, 0.01));
    });
  });
}
