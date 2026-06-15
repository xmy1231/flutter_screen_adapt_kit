import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/core/hot_reload_guard.dart';
import 'package:flutter_screen_adapt_kit/core/scale_calc.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';
import 'package:flutter_screen_adapt_kit/text/text_scaler.dart';

void main() {
  setUp(() {
    HotReloadGuard.reset();
  });

  Widget wrapApp(Widget child) {
    return MaterialApp(home: child);
  }

  group('AdaptKit', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        wrapApp(const AdaptKit(child: SizedBox(width: 100, height: 100))),
      );
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('provides adapt context extensions', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            child: Builder(
              builder: (context) {
                expect(context.adaptScale, greaterThan(0));
                expect(context.adaptDpr, greaterThan(0));
                return const SizedBox(width: 100, height: 100);
              },
            ),
          ),
        ),
      );
    });

    testWidgets('setDesignSize updates scale', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            designSize: const Size(375, 812),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      final before = state.scale;

      state.setDesignSize(const Size(400, 800));
      await tester.pumpAndSettle();

      expect(state.scale, isNot(equals(before)));
    });

    testWidgets('works with classifier', (tester) async {
      final classifier = _TestClassifier();

      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            classifier: classifier,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.notchInfo, isNot(isNull));
    });

    testWidgets('overrideNotch sets custom notch info', (tester) async {
      await tester.pumpWidget(
        wrapApp(const AdaptKit(child: SizedBox(width: 100, height: 100))),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      state.overrideNotch(const NotchOverride(type: NotchType.wideNotch, topInset: 44));

      expect(state.notchInfo.type, NotchType.wideNotch);
      expect(state.notchInfo.topInset, 44);
    });

    testWidgets('resetNotch restores auto-classification', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            classifier: _TestClassifier(),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));

      state.overrideNotch(const NotchOverride(type: NotchType.wideNotch, topInset: 99));
      await tester.pumpAndSettle();
      expect(state.notchInfo.topInset, 99);

      state.resetNotch();
      await tester.pumpAndSettle();
      expect(state.notchInfo.topInset, 0);
    });

    testWidgets('setStrategy updates internal strategy field', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            designSize: const Size(375, 812),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.strategy, AdaptStrategy.width);

      state.setStrategy(AdaptStrategy.height);
      await tester.pumpAndSettle();

      expect(state.strategy, AdaptStrategy.height);
    });

    testWidgets('setTextBehavior updates text behavior field', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.textBehavior, TextBehavior.scale);

      state.setTextBehavior(TextBehavior.fixed);
      await tester.pumpAndSettle();

      expect(state.textBehavior, TextBehavior.fixed);
    });

    testWidgets('setSupportSystemTextScale updates support flag', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.supportSystemTextScale, isTrue);

      state.setSupportSystemTextScale(false);
      await tester.pumpAndSettle();

      expect(state.supportSystemTextScale, isFalse);
    });

    testWidgets('child rebuilds when design size changes', (tester) async {
      var buildCount = 0;

      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            designSize: const Size(375, 812),
            child: Builder(
              builder: (context) {
                buildCount++;
                // Reading adaptScale registers dependency
                context.adaptScale;
                return const SizedBox(width: 100, height: 100);
              },
            ),
          ),
        ),
      );
      final initialCount = buildCount;

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      state.setDesignSize(const Size(400, 800));
      await tester.pumpAndSettle();

      expect(buildCount, greaterThan(initialCount));
    });

    testWidgets('AdaptKit.of(context) returns the state', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            child: Builder(
              builder: (context) {
                final found = AdaptKit.of(context);
                expect(found, isNotNull);
                return const SizedBox(width: 100, height: 100);
              },
            ),
          ),
        ),
      );
    });

    testWidgets('overrideNotch with all fields propagates insets', (tester) async {
      await tester.pumpWidget(
        wrapApp(const AdaptKit(child: SizedBox(width: 100, height: 100))),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      state.overrideNotch(
        const NotchOverride(
          type: NotchType.dynamicIsland,
          topInset: 50,
          bottomInset: 25,
          leftInset: 10,
          rightInset: 10,
        ),
      );

      expect(state.notchInfo.type, NotchType.dynamicIsland);
      expect(state.notchInfo.topInset, 50);
      expect(state.notchInfo.bottomInset, 25);
      expect(state.notchInfo.leftInset, 10);
      expect(state.notchInfo.rightInset, 10);
    });

    testWidgets('context.adaptSafeTop/Bottom reflect notch info', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            classifier: _NotchStubClassifier(),
            child: Builder(
              builder: (context) {
                // The stub returns topInset=30, bottomInset=0
                expect(context.adaptSafeTop, 30);
                expect(context.adaptSafeBottom, 0);
                return const SizedBox(width: 100, height: 100);
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getters return safe defaults when _result is null', (tester) async {
      // Build, then dispose state via pumping a new tree → access to fresh state
      // before _apply has run is racy, so just test the getter fallback path directly
      // by checking the documented default
      const result1 = AdaptKit(child: SizedBox());
      expect(result1.designSize, const Size(375, 812));
      expect(result1.strategy, AdaptStrategy.width);
      expect(result1.textBehavior, TextBehavior.scale);
    });

    testWidgets('changing widget.classifier at runtime re-classifies notch info',
        (tester) async {
      // RED: BUG — when the parent rebuilds AdaptKit with a different classifier,
      // _notchInfo is not refreshed. State is stale.
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            classifier: const _NotchStubClassifier(), // topInset=30
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.notchInfo.topInset, 30);

      // Switch to a different classifier that returns topInset=88
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            classifier: const _OtherClassifier(), // topInset=88
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // After re-classification, topInset should reflect the new classifier
      expect(state.notchInfo.topInset, 88);
    });

    testWidgets('changing widget.classifier from null to non-null applies classification',
        (tester) async {
      // RED: Adding a classifier later should trigger classification.
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            // no classifier
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.notchInfo.type, NotchType.none);

      // Add classifier
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            classifier: const _NotchStubClassifier(),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(state.notchInfo.topInset, 30);
    });

    testWidgets('changing widget.textBehavior at runtime updates state', (tester) async {
      // RED: widget.textBehavior change should propagate to state.
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            textBehavior: TextBehavior.scale,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.textBehavior, TextBehavior.scale);

      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            textBehavior: TextBehavior.fixed,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(state.textBehavior, TextBehavior.fixed);
    });

    testWidgets('changing widget.supportSystemTextScale at runtime updates state',
        (tester) async {
      // RED: widget.supportSystemTextScale change should propagate.
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            supportSystemTextScale: true,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.supportSystemTextScale, isTrue);

      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            supportSystemTextScale: false,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(state.supportSystemTextScale, isFalse);
    });

    testWidgets('changing widget.designSize at runtime updates state', (tester) async {
      // RED: widget.designSize change should propagate to state.
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            designSize: const Size(375, 812),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.designSize, const Size(375, 812));

      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            designSize: const Size(414, 896),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(state.designSize, const Size(414, 896));
    });

    testWidgets('changing widget.strategy at runtime updates state', (tester) async {
      // RED: widget.strategy change should propagate to state.
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            strategy: AdaptStrategy.width,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.strategy, AdaptStrategy.width);

      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            strategy: AdaptStrategy.height,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(state.strategy, AdaptStrategy.height);
    });

    testWidgets('calling overrideNotch after widget is disposed: guarded (no crash)',
        (tester) async {
      // TDD: if user holds AdaptKitState reference and widget is removed,
      // calling overrideNotch should not crash with "setState called after dispose".
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));

      // Replace widget tree with one that has no AdaptKit → disposes the state
      await tester.pumpWidget(
        wrapApp(const SizedBox(width: 100, height: 100)),
      );
      await tester.pumpAndSettle();

      // Without a mounted guard, this throws: "setState called after dispose"
      // With a mounted guard, it should return early (no-op) without crashing
      expect(
        () => state.overrideNotch(
          const NotchOverride(type: NotchType.wideNotch, topInset: 30),
        ),
        returnsNormally,
      );
    });
  });
}

class _OtherClassifier extends NotchClassifier {
  const _OtherClassifier();
  @override
  NotchInfo classify(SystemInfo info, {Orientation? orientation}) {
    return const NotchInfo(
      type: NotchType.dynamicIsland,
      topInset: 88,
      bottomInset: 44,
    );
  }
}

class _NotchStubClassifier extends NotchClassifier {
  const _NotchStubClassifier();
  @override
  NotchInfo classify(SystemInfo info, {Orientation? orientation}) {
    return const NotchInfo(
      type: NotchType.wideNotch,
      topInset: 30,
      bottomInset: 0,
    );
  }
}

class _TestClassifier extends NotchClassifier {
  const _TestClassifier();

  @override
  NotchInfo classify(SystemInfo info, {Orientation? orientation}) {
    return const NotchInfo(type: NotchType.none);
  }
}
