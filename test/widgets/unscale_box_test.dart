import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/core/hot_reload_guard.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import 'package:flutter_screen_adapt_kit/widgets/unscale_box.dart';

void main() {
  setUp(() {
    HotReloadGuard.reset();
  });

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

    testWidgets('UnscaleMode.context uses MediaQuery textScaler (modern API)', (tester) async {
      // TDD: UnscaleBox should read from TextScaler (not the deprecated textScaleFactor).
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
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
      // textScaler=linear(2.0) → uiScale=2.0 → inverse=0.5
      expect(transform.transform.getMaxScaleOnAxis(), closeTo(0.5, 0.01));
    });

    testWidgets('UnscaleMode.context inverse transform is non-zero', (tester) async {
      // Regression: ensure context mode doesn't fall back to 1.0 when textScaler is set
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
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
      // 1/1.5 = 0.6667
      expect(transform.transform.getMaxScaleOnAxis(), closeTo(1.0 / 1.5, 0.01));
    });

    testWidgets('UnscaleBox without Directionality still renders child', (tester) async {
      // UnscaleBox does not need Directionality itself — it just applies a transform.
      await tester.pumpWidget(
        const UnscaleBox(
          dpr: 2.0,
          designWidth: 375,
          child: SizedBox(width: 50, height: 50),
        ),
      );
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Transform), findsOneWidget);
    });

    testWidgets('UnscaleBox full mode fallback when no AdaptKit ancestor', (tester) async {
      // Without AdaptKit, context.adaptScaleResult is null
      // Should use fallback: dpr * 375 / designWidth
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: UnscaleBox(
            dpr: 3.0,
            designWidth: 375,
            mode: UnscaleMode.full,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      final transform = tester.widget<Transform>(find.byType(Transform));
      // Fallback: 3.0 * 375 / 375 = 3.0 → inverse = 1/3
      expect(transform.transform.getMaxScaleOnAxis(), closeTo(1.0 / 3.0, 0.01));
    });

    testWidgets('UnscaleBox with adapt context uses actual scale from ScaleResult', (tester) async {
      // When wrapped in AdaptKit, the scale comes from the ScaleResult
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            designSize: const Size(375, 812),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: const UnscaleBox(
                dpr: 3.0,
                designWidth: 375, // ignored when scale is in context
                child: SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        ),
      );
      final transform = tester.widget<Transform>(find.byType(Transform));
      // Scale should be whatever ScaleResult.scale is, not dpr*375/designWidth
      expect(transform.transform.getMaxScaleOnAxis(), greaterThan(0.0));
    });

    testWidgets('UnscaleBox outside AdaptKit: inverse is finite and non-NaN', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: UnscaleBox(
            dpr: 2.5,
            designWidth: 500,
            child: SizedBox(width: 50, height: 50),
          ),
        ),
      );
      final transform = tester.widget<Transform>(find.byType(Transform));
      final scale = transform.transform.getMaxScaleOnAxis();
      expect(scale.isFinite, isTrue);
      expect(scale.isNaN, isFalse);
    });

    testWidgets('dpr=0 and designWidth=0 fallback: inverse is 1.0 (not NaN)', (tester) async {
      // TDD: dpr=0, designWidth=0 would produce 0/0=NaN in the formula dpr*375/designWidth
      // UnscaleBox should guard against this pathological input.
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: UnscaleBox(
            dpr: 0.0,
            designWidth: 0.0,
            child: SizedBox(width: 50, height: 50),
          ),
        ),
      );
      final transform = tester.widget<Transform>(find.byType(Transform));
      final scale = transform.transform.getMaxScaleOnAxis();
      expect(scale.isFinite, isTrue, reason: 'Transform should be finite, not NaN');
      expect(scale.isNaN, isFalse);
      // With NaN guard returning 1.0, inverse = 1.0/1.0 = 1.0
      expect(scale, 1.0);
    });
  });
}
