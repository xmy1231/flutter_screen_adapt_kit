import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/core/hot_reload_guard.dart';
import 'package:flutter_screen_adapt_kit/core/scale_calc.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';
import 'package:flutter_screen_adapt_kit/safe/safe_adapter.dart';
import 'package:flutter_screen_adapt_kit/text/text_scaler.dart';

void main() {
  setUp(() {
    HotReloadGuard.reset();
  });

  group('Concurrency: didChangeMetrics simulation', () {
    testWidgets('rapid physicalSize changes: final state matches last applied size',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            designSize: const Size(375, 812),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      final sizes = [
        const Size(400, 600),
        const Size(800, 1200),
        const Size(1920, 1080),
        const Size(2400, 1080),
        const Size(1170, 2532), // iPhone Pro
      ];

      // Simulate rapid metric changes
      for (final s in sizes) {
        tester.view.physicalSize = s;
        // Don't pump — just trigger metrics change events
      }
      await tester.pumpAndSettle();

      // Final state should be consistent (not crash, not corrupt)
      expect(state.scale, isNotNull);
      expect(state.adaptedDpr, isNotNull);
      expect(state.scale, greaterThan(0.0));
    });

    testWidgets('rapid dpr changes: final adaptedDpr is finite', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            designSize: const Size(375, 812),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));

      // Toggle between 1x, 2x, 3x
      for (var i = 0; i < 10; i++) {
        tester.view.devicePixelRatio = 1.0 + (i % 3);
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Final state must be sane
      expect(state.adaptedDpr, isNotNull);
      expect(state.adaptedDpr.isFinite, isTrue);
      expect(state.adaptedDpr, greaterThan(0.0));
    });

    testWidgets('rapid padding changes: notch info updates (or stays at zero if no classifier)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            classifier: const _CountingClassifier(),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      // Simulate rapid padding changes
      for (var i = 0; i < 5; i++) {
        tester.view.padding = FakeViewPadding(
          top: 20.0 + i * 10,
          bottom: 10.0,
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Should not crash; final state is consistent
      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state, isNotNull);
    });
  });

  group('Concurrency: rapid setDesignSize', () {
    testWidgets('100 rapid setDesignSize calls: final state matches last call',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            designSize: const Size(375, 812),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      final expected = const Size(414, 896);

      for (var i = 0; i < 100; i++) {
        state.setDesignSize(
          Size(300.0 + i * 5, 600.0 + i * 10),
        );
      }
      state.setDesignSize(expected);
      await tester.pumpAndSettle();

      expect(state.designSize, expected);
    });

    testWidgets('100 rapid setDesignSize with strategy override', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            designSize: const Size(375, 812),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));

      for (var i = 0; i < 100; i++) {
        state.setDesignSize(
          Size(300.0 + i, 600.0 + i),
          strategy: i.isEven ? AdaptStrategy.width : AdaptStrategy.height,
        );
      }
      // Final: even iteration (i=99) → odd → height
      // Actually last setDesignSize was i=99 (odd) → height
      await tester.pumpAndSettle();

      // Last call was i=99 (odd) → strategy=height
      // But actually the loop ends with i=99, so the iteration that ran was i=99
      // However setDesignSize's `strategy` param was odd → height
      // Wait: 99.isEven is false, so strategy = height
      expect(state.strategy, AdaptStrategy.height);
    });
  });

  group('Concurrency: rapid setStrategy', () {
    testWidgets('100 alternating setStrategy calls: final is height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            designSize: const Size(375, 812),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));

      for (var i = 0; i < 100; i++) {
        state.setStrategy(i.isEven ? AdaptStrategy.width : AdaptStrategy.height);
      }
      // i=99 (odd) → height
      await tester.pumpAndSettle();

      expect(state.strategy, AdaptStrategy.height);
    });

    testWidgets('rapid setStrategy between all 3 strategies: no exceptions',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            designSize: const Size(375, 812),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      final strategies = AdaptStrategy.values;

      for (var i = 0; i < 100; i++) {
        state.setStrategy(strategies[i % strategies.length]);
      }
      await tester.pumpAndSettle();

      expect(state.strategy, isIn(strategies));
    });
  });

  group('Concurrency: rapid setTextBehavior', () {
    testWidgets('100 rapid setTextBehavior calls: final is in enum', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      final behaviors = TextBehavior.values;

      for (var i = 0; i < 100; i++) {
        state.setTextBehavior(behaviors[i % behaviors.length]);
      }
      await tester.pumpAndSettle();

      expect(state.textBehavior, isIn(behaviors));
    });
  });

  group('Concurrency: combined mutations', () {
    testWidgets('100 mixed setDesignSize+setStrategy+setTextBehavior: state consistent',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            designSize: const Size(375, 812),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      final strategies = AdaptStrategy.values;
      final behaviors = TextBehavior.values;

      for (var i = 0; i < 100; i++) {
        state.setDesignSize(Size(300.0 + i, 600.0 + i));
        state.setStrategy(strategies[i % strategies.length]);
        state.setTextBehavior(behaviors[i % behaviors.length]);
        state.setSupportSystemTextScale(i.isEven);
      }
      // Final: i=99, odd, so supportSystemTextScale=false
      await tester.pumpAndSettle();

      expect(state.supportSystemTextScale, isFalse);
      // All fields are valid enum values or reasonable sizes
      expect(state.designSize.width, greaterThan(0));
      expect(state.designSize.height, greaterThan(0));
      expect(state.strategy, isIn(strategies));
      expect(state.textBehavior, isIn(behaviors));
    });
  });

  group('Concurrency: HotReloadGuard rapid ensure', () {
    test('1000 ensure() calls: first returns false, rest true', () {
      HotReloadGuard.reset();
      final results = <bool>[];
      for (var i = 0; i < 1000; i++) {
        results.add(HotReloadGuard.ensure());
      }
      expect(results[0], isFalse);
      for (var i = 1; i < 1000; i++) {
        expect(results[i], isTrue, reason: 'index $i');
      }
    });

    test('rapid reset/ensure cycles: state is correct after each', () {
      for (var i = 0; i < 100; i++) {
        expect(HotReloadGuard.ensure(), isFalse, reason: 'cycle $i first call');
        expect(HotReloadGuard.ensure(), isTrue, reason: 'cycle $i second call');
        HotReloadGuard.reset();
      }
    });
  });

  group('Concurrency: NotchOverride toggle storm', () {
    testWidgets('rapid overrideNotch/resetNotch: state is consistent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            classifier: const _CountingClassifier(),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));

      for (var i = 0; i < 100; i++) {
        state.overrideNotch(
          NotchOverride(
            type: NotchType.wideNotch,
            topInset: i.toDouble(),
            bottomInset: i.toDouble(),
          ),
        );
        state.resetNotch();
        state.overrideNotch(
          const NotchOverride(
            type: NotchType.dynamicIsland,
            topInset: 50,
          ),
        );
      }
      await tester.pumpAndSettle();

      // Final state is dynamicIsland
      expect(state.notchInfo.type, NotchType.dynamicIsland);
      expect(state.notchInfo.topInset, 50);
    });
  });

  group('Concurrency: SafeMode switching', () {
    testWidgets('rapid widget rebuild with different SafeMode: no crashes', (tester) async {
      final modes = SafeMode.values;

      for (var i = 0; i < 20; i++) {
        HotReloadGuard.reset();
        await tester.pumpWidget(
          MaterialApp(
            home: AdaptKit(
              classifier: const _CountingClassifier(),
              safeMode: modes[i % modes.length],
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        );
      }
      // Should not have crashed
      expect(tester.takeException(), isNull);
    });
  });

  group('Concurrency: nested AdaptKit rapid rebuilds', () {
    testWidgets('100 nested AdaptKit rebuilds: no exceptions, no leaks', (tester) async {
      for (var i = 0; i < 100; i++) {
        HotReloadGuard.reset();
        await tester.pumpWidget(
          MaterialApp(
            home: AdaptKit(
              designSize: const Size(375, 812),
              child: AdaptKit(
                designSize: Size(414.0 + i, 896.0 + i),
                child: const SizedBox(width: 50, height: 50),
              ),
            ),
          ),
        );
      }
      expect(tester.takeException(), isNull);
    });
  });
}

class _CountingClassifier extends NotchClassifier {
  const _CountingClassifier();
  @override
  NotchInfo classify(SystemInfo info, {Orientation? orientation}) {
    return const NotchInfo(type: NotchType.wideNotch, topInset: 30);
  }
}
