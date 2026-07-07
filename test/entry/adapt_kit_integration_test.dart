import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/core/hot_reload_guard.dart';
import 'package:flutter_screen_adapt_kit/core/scale_calc.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import 'package:flutter_screen_adapt_kit/safe/android_classifier.dart';
import 'package:flutter_screen_adapt_kit/safe/harmony_classifier.dart';
import 'package:flutter_screen_adapt_kit/safe/ios_classifier.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';
import 'package:flutter_screen_adapt_kit/safe/safe_adapter.dart';
import 'package:flutter_screen_adapt_kit/text/text_scaler.dart';

void main() {
  setUp(() {
    HotReloadGuard.reset();
  });

  Widget wrapApp(Widget child) => MaterialApp(home: child);

  group('AdaptKit + classifier integration', () {
    testWidgets('iOS classifier drives state.notchInfo', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            classifier: const IOSNotchClassifier(),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.notchInfo, isNotNull);
    });

    testWidgets('overrideNotch bypasses classifier', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            classifier: const IOSNotchClassifier(),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      state.overrideNotch(
        const NotchOverride(
            type: NotchType.dynamicIsland, topInset: 59, bottomInset: 34),
      );
      expect(state.notchInfo.type, NotchType.dynamicIsland);
      expect(state.notchInfo.topInset, 59);
      expect(state.notchInfo.bottomInset, 34);
    });

    testWidgets('resetNotch restores classifier-driven classification',
        (tester) async {
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            classifier: const IOSNotchClassifier(),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );
      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      state.overrideNotch(const NotchOverride(
          type: NotchType.dynamicIsland, topInset: 59, bottomInset: 34));
      expect(state.notchInfo.topInset, 59);

      state.resetNotch();
      expect(state.notchInfo.topInset, 0);
    });

    testWidgets('cross-platform: 3 different classifiers all wire up',
        (tester) async {
      await tester.pumpWidget(wrapApp(AdaptKit(
          classifier: const IOSNotchClassifier(), child: const SizedBox())));
      final iosState = tester.state<AdaptKitState>(find.byType(AdaptKit));

      await tester.pumpWidget(wrapApp(AdaptKit(
          classifier: const AndroidNotchClassifier(),
          child: const SizedBox())));
      final androidState = tester.state<AdaptKitState>(find.byType(AdaptKit));

      await tester.pumpWidget(wrapApp(AdaptKit(
          classifier: const HarmonyOSNotchClassifier(),
          child: const SizedBox())));
      final harmonyState = tester.state<AdaptKitState>(find.byType(AdaptKit));

      expect(iosState.notchInfo, isNotNull);
      expect(androidState.notchInfo, isNotNull);
      expect(harmonyState.notchInfo, isNotNull);
    });
  });

  group('AdaptKit state mutation', () {
    testWidgets('setStrategy updates state.strategy', (tester) async {
      await tester.pumpWidget(
        wrapApp(
            AdaptKit(strategy: AdaptStrategy.width, child: const SizedBox())),
      );
      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.strategy, AdaptStrategy.width);

      state.setStrategy(AdaptStrategy.height);
      await tester.pumpAndSettle();
      expect(state.strategy, AdaptStrategy.height);
    });

    testWidgets('setTextBehavior updates state.textBehavior', (tester) async {
      await tester.pumpWidget(
        wrapApp(AdaptKit(child: const SizedBox())),
      );
      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.textBehavior, TextBehavior.scale);

      state.setTextBehavior(TextBehavior.fixed);
      expect(state.textBehavior, TextBehavior.fixed);
    });

    testWidgets('setSupportSystemTextScale updates state', (tester) async {
      await tester.pumpWidget(
        wrapApp(AdaptKit(child: const SizedBox())),
      );
      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.supportSystemTextScale, true);

      state.setSupportSystemTextScale(false);
      expect(state.supportSystemTextScale, false);
    });

    testWidgets('setDesignSize with strategy override updates both',
        (tester) async {
      await tester.pumpWidget(
        wrapApp(
          AdaptKit(
            designSize: const Size(375, 812),
            strategy: AdaptStrategy.width,
            child: const SizedBox(),
          ),
        ),
      );
      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      expect(state.designSize, const Size(375, 812));
      expect(state.strategy, AdaptStrategy.width);

      state.setDesignSize(const Size(430, 932), strategy: AdaptStrategy.height);
      await tester.pumpAndSettle();
      expect(state.designSize, const Size(430, 932));
      expect(state.strategy, AdaptStrategy.height);
    });
  });

  group('AdaptContext extensions full coverage', () {
    testWidgets('returns sensible defaults outside AdaptKit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _ContextProbe(),
          ),
        ),
      );

      final probe = tester.widget<_ProbeData>(find.byType(_ProbeData));
      expect(probe.scale, 1.0);
      expect(probe.dpr, 1.0);
      expect(probe.safeTop, 0);
      expect(probe.safeBottom, 0);
      expect(probe.notchInfo, isNull);
      expect(probe.scaleResult, isNull);
      expect(probe.textBehavior, TextBehavior.scale);
      expect(probe.supportSystemTextScale, true);
      expect(probe.statusBarHeight, 0);
      expect(probe.notchHeight, 0);
    });

    testWidgets('returns real values inside AdaptKit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            designSize: const Size(375, 812),
            child: const Scaffold(body: _ContextProbe()),
          ),
        ),
      );

      final probe = tester.widget<_ProbeData>(find.byType(_ProbeData));
      expect(probe.scale, greaterThan(0));
      expect(probe.dpr, greaterThan(0));
      expect(probe.scaleResult, isNotNull);
    });

    testWidgets('textBehavior propagates through context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            textBehavior: TextBehavior.fixed,
            child: const Scaffold(body: _ContextProbe()),
          ),
        ),
      );

      final probe = tester.widget<_ProbeData>(find.byType(_ProbeData));
      expect(probe.textBehavior, TextBehavior.fixed);
    });

    testWidgets('supportSystemTextScale propagates through context',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            supportSystemTextScale: false,
            child: const Scaffold(body: _ContextProbe()),
          ),
        ),
      );

      final probe = tester.widget<_ProbeData>(find.byType(_ProbeData));
      expect(probe.supportSystemTextScale, false);
    });
  });

  group('AdaptKit.of from descendant', () {
    testWidgets('finds AdaptKitState from any descendant context',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            child: Builder(
              builder: (context) {
                return Text('state=${AdaptKit.of(context) != null}');
              },
            ),
          ),
        ),
      );
      expect(find.text('state=true'), findsOneWidget);
    });

    testWidgets('returns null when no AdaptKit ancestor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Text('state=${AdaptKit.of(context) != null}');
            },
          ),
        ),
      );
      expect(find.text('state=false'), findsOneWidget);
    });
  });

  group('AdaptKit + SafeAdapter wrapping', () {
    testWidgets('wraps child in SafeAdapter when notch present',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            classifier: const IOSNotchClassifier(),
            safeMode: SafeMode.auto,
            child: Builder(
              builder: (context) => const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );

      final state = tester.state<AdaptKitState>(find.byType(AdaptKit));
      state.overrideNotch(
          const NotchOverride(type: NotchType.wideNotch, topInset: 44));
      await tester.pumpAndSettle();

      expect(find.byType(SafeAdapter), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('does NOT wrap in SafeAdapter when no classifier',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            child: Builder(
              builder: (context) => const SizedBox(width: 50, height: 50),
            ),
          ),
        ),
      );
      expect(find.byType(SafeAdapter), findsNothing);
    });
  });
}

class _ContextProbe extends StatelessWidget {
  const _ContextProbe();

  @override
  Widget build(BuildContext context) {
    return _ProbeData(
      scale: context.adaptScale,
      dpr: context.adaptSystemInfo?.dpr ?? 1.0,
      safeTop: context.adaptSafeTop,
      safeBottom: context.adaptSafeBottom,
      notchInfo: context.adaptNotchInfo,
      scaleResult: context.adaptScaleResult,
      textBehavior: context.adaptTextBehavior,
      supportSystemTextScale: context.adaptSupportSystemTextScale,
      statusBarHeight: context.statusBarHeight,
      notchHeight: context.notchHeight,
      child: const SizedBox(width: 10, height: 10),
    );
  }
}

class _ProbeData extends StatelessWidget {
  final double scale;
  final double dpr;
  final double safeTop;
  final double safeBottom;
  final NotchInfo? notchInfo;
  final ScaleResult? scaleResult;
  final TextBehavior textBehavior;
  final bool supportSystemTextScale;
  final double statusBarHeight;
  final double notchHeight;
  final Widget child;

  const _ProbeData({
    required this.scale,
    required this.dpr,
    required this.safeTop,
    required this.safeBottom,
    required this.notchInfo,
    required this.scaleResult,
    required this.textBehavior,
    required this.supportSystemTextScale,
    required this.statusBarHeight,
    required this.notchHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
