import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/core/hot_reload_guard.dart';
import 'package:flutter_adapt_kit/core/scale_calc.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';
import 'package:flutter_adapt_kit/entry/adapt_kit.dart';
import 'package:flutter_adapt_kit/safe/notch_classifier.dart';
import 'package:flutter_adapt_kit/safe/safe_adapter.dart';
import 'package:flutter_adapt_kit/text/text_scaler.dart';
import 'package:flutter_adapt_kit/widgets/physical_pixel_box.dart';
import 'package:flutter_adapt_kit/widgets/unscale_box.dart';

void main() {
  group('Negative: TextScaler edge values', () {
    test('uiScale=0, fixed mode returns 1.0', () {
      final factor = TextScaleDecider.compute(
        uiScale: 0,
        behavior: TextBehavior.fixed,
      );
      expect(factor, 1.0);
    });

    test('uiScale=0, scale mode returns 0', () {
      // Edge: caller responsible for non-zero uiScale
      final factor = TextScaleDecider.compute(
        uiScale: 0,
        behavior: TextBehavior.scale,
        supportSystemTextScale: false,
      );
      expect(factor, 0.0);
    });

    test('systemTextScale=0, system mode returns 0', () {
      final factor = TextScaleDecider.compute(
        uiScale: 1.5,
        systemTextScale: 0,
        behavior: TextBehavior.system,
      );
      expect(factor, 0.0);
    });

    test('negative values pass through (caller is responsible)', () {
      final factor = TextScaleDecider.compute(
        uiScale: -1.0,
        behavior: TextBehavior.scale,
        supportSystemTextScale: false,
      );
      expect(factor, -1.0);
    });

    test('very large values do not throw', () {
      final factor = TextScaleDecider.compute(
        uiScale: 1e10,
        systemTextScale: 1e10,
        behavior: TextBehavior.scale,
        supportSystemTextScale: true,
      );
      // Just verify it doesn't throw / produce NaN
      expect(factor.isFinite, isTrue);
      expect(factor.isNaN, isFalse);
    });
  });

  group('Negative: NotchInfo edge values', () {
    test('zero insets produces zero EdgeInsets', () {
      const info = NotchInfo(type: NotchType.wideNotch);
      expect(info.insets, EdgeInsets.zero);
    });

    test('negative insets are preserved verbatim', () {
      const info = NotchInfo(
        type: NotchType.wideNotch,
        topInset: -10,
        bottomInset: -5,
      );
      expect(info.topInset, -10);
      expect(info.bottomInset, -5);
    });

    test('very large insets do not overflow', () {
      const info = NotchInfo(
        type: NotchType.wideNotch,
        topInset: 1e9,
        bottomInset: 1e9,
      );
      expect(info.topInset, 1e9);
      expect(info.bottomInset, 1e9);
    });

    test('empty cutoutRects is a valid list', () {
      const info = NotchInfo(type: NotchType.wideNotch);
      expect(info.cutoutRects, isEmpty);
      expect(info.cutoutRects, isA<List>());
    });
  });

  group('Negative: HotReloadGuard state machine', () {
    setUp(() {
      HotReloadGuard.reset();
    });

    test('reset() when already reset is idempotent', () {
      HotReloadGuard.reset();
      HotReloadGuard.reset();
      expect(HotReloadGuard.isInitialized, false);
    });

    test('ensure → reset → ensure returns false (re-initialization)', () {
      expect(HotReloadGuard.ensure(), false);
      HotReloadGuard.reset();
      expect(HotReloadGuard.isInitialized, false);
      expect(HotReloadGuard.ensure(), false);
    });

    test('many consecutive ensure() calls all return true after first', () {
      HotReloadGuard.ensure();
      for (var i = 0; i < 10; i++) {
        expect(HotReloadGuard.ensure(), true);
      }
    });
  });

  group('Negative: UnscaleBox degenerate inputs', () {
    testWidgets('dpr=0 with full mode does not crash', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: UnscaleBox(
            dpr: 0,
            designWidth: 375,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      // Should not throw
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('designWidth=0 with full mode does not crash', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: UnscaleBox(
            dpr: 3.0,
            designWidth: 0,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('UnscaleBox outside AdaptKit context falls back to defaults', (tester) async {
      // No AdaptKit ancestor, so adaptScaleResult is null
      // Should fall back to dpr * 375 / designWidth
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: UnscaleBox(
            dpr: 2.0,
            designWidth: 400, // 2.0 * 375 / 400 = 1.875
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      final transform = tester.widget<Transform>(find.byType(Transform));
      // Inverse of 1.875 ≈ 0.533
      expect(transform.transform.getMaxScaleOnAxis(), closeTo(0.533, 0.01));
    });
  });

  group('Negative: PhysicalPixelBox edge cases', () {
    testWidgets('width=0 produces no border', (tester) async {
      await tester.pumpWidget(
        const PhysicalPixelBox(
          dpr: 3.0,
          width: 0,
          child: SizedBox(width: 100, height: 100),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container));
      final border = (container.decoration as BoxDecoration).border;
      // Border.all with width=0 still creates a Border, just with 0 width
      expect(border, isNotNull);
    });

    testWidgets('dpr=0 does not crash (width=1)', (tester) async {
      await tester.pumpWidget(
        const PhysicalPixelBox(
          dpr: 0,
          width: 1,
          child: SizedBox(width: 100, height: 100),
        ),
      );
      // Should not throw; child renders
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('width=0 with dpr=0 does not crash', (tester) async {
      await tester.pumpWidget(
        const PhysicalPixelBox(
          dpr: 0,
          width: 0,
          child: SizedBox(width: 100, height: 100),
        ),
      );
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('Negative: ScaleCalc zero-size combinations', () {
    test('both zero returns 1.0 (guard active)', () {
      final info = SystemInfo(logicalSize: Size.zero);
      final result = ScaleCalc.compute(info, Size.zero, AdaptStrategy.width);
      expect(result.scale, 1.0);
    });

    test('zero design with height strategy returns 1.0', () {
      final info = SystemInfo(logicalSize: const Size(390, 844));
      final result = ScaleCalc.compute(info, Size.zero, AdaptStrategy.height);
      expect(result.scale, 1.0);
    });

    test('zero design with min strategy returns 1.0', () {
      final info = SystemInfo(logicalSize: const Size(390, 844));
      final result = ScaleCalc.compute(info, Size.zero, AdaptStrategy.min);
      expect(result.scale, 1.0);
    });

    test('zero logical with all 3 strategies returns 1.0', () {
      final info = SystemInfo(logicalSize: Size.zero);
      for (final strategy in AdaptStrategy.values) {
        final result = ScaleCalc.compute(info, const Size(375, 812), strategy);
        expect(result.scale, 1.0, reason: 'strategy=$strategy');
      }
    });
  });

  group('Negative: SafeAdapter edge insets', () {
    testWidgets('all 4 SafeModes with NotchInfo.zero produce no padding', (tester) async {
      for (final mode in SafeMode.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: SafeAdapter(
              notchInfo: NotchInfo.zero,
              mode: mode,
              child: const Text('test'),
            ),
          ),
        );
        expect(find.byType(Padding), findsNothing, reason: 'mode=$mode');
      }
    });

    testWidgets('negative top inset triggers Flutter Padding assertion (documented behavior)', (tester) async {
      // Negative insets cause Flutter's Padding to throw an assertion
      // because padding.isNonNegative must be true. This documents that
      // SafeAdapter does NOT validate/sanitize inputs.
      await tester.pumpWidget(
        MaterialApp(
          home: const SafeAdapter(
            notchInfo: NotchInfo(type: NotchType.wideNotch, topInset: -10),
            mode: SafeMode.maximum,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      // The assertion is captured by the test framework via takeException
      expect(tester.takeException(), isA<AssertionError>());
    });

    testWidgets('all 4 sides set produce 4-side padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SafeAdapter(
            notchInfo: NotchInfo(
              type: NotchType.wideNotch,
              topInset: 44,
              bottomInset: 34,
              leftInset: 10,
              rightInset: 5,
            ),
            mode: SafeMode.maximum,
            child: Text('test'),
          ),
        ),
      );
      final padding = tester.widget<Padding>(find.byType(Padding));
      final insets = padding.padding as EdgeInsets;
      expect(insets.top, 44);
      expect(insets.bottom, 34);
      expect(insets.left, 10);
      expect(insets.right, 5);
    });
  });

  group('Negative: AdaptKit nested behavior', () {
    testWidgets('inner AdaptKit state is the nearest ancestor for AdaptKit.of', (tester) async {
      final captured = <AdaptKitState?>[];

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            designSize: const Size(375, 812),
            child: AdaptKit(
              designSize: const Size(430, 932),
              child: Builder(
                builder: (context) {
                  captured.add(AdaptKit.of(context));
                  return const SizedBox(width: 50, height: 50);
                },
              ),
            ),
          ),
        ),
      );

      // The nearest AdaptKit ancestor is the inner one with designSize 430x932
      expect(captured.length, 1);
      expect(captured.first?.designSize, const Size(430, 932));
    });

    testWidgets('two siblings share the same outer AdaptKit state (no inner)', (tester) async {
      final captured = <AdaptKitState?>[];

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            designSize: const Size(375, 812),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (context) {
                    captured.add(AdaptKit.of(context));
                    return const SizedBox(width: 50, height: 50);
                  },
                ),
                Builder(
                  builder: (context) {
                    captured.add(AdaptKit.of(context));
                    return const SizedBox(width: 50, height: 50);
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Both siblings see the same outer state
      expect(captured.length, 2);
      expect(captured[0], isNotNull);
      expect(captured[1], isNotNull);
      expect(identical(captured[0], captured[1]), isTrue);
      expect(captured[0]?.designSize, const Size(375, 812));
    });
  });

  group('Negative: SystemInfo edge cases', () {
    test('fromMediaQuery with zero size works', () {
      final mq = MediaQueryData(
        size: Size.zero,
        devicePixelRatio: 1.0,
      );
      final info = SystemInfo.fromMediaQuery(mq);
      expect(info.logicalSize, Size.zero);
      expect(info.dpr, 1.0);
    });

    test('fromMediaQuery with negative padding', () {
      final mq = MediaQueryData(
        size: const Size(390, 844),
        devicePixelRatio: 3.0,
        padding: const EdgeInsets.only(top: -10),
      );
      final info = SystemInfo.fromMediaQuery(mq);
      expect(info.padding.top, -10);
    });

    test('equality across distinct instances with same values', () {
      final a = SystemInfo(physicalSize: const Size(100, 200), dpr: 2.0);
      final b = SystemInfo(physicalSize: const Size(100, 200), dpr: 2.0);
      expect(a, b);
      // Verify they are distinct instances
      expect(identical(a, b), false);
    });
  });
}
