import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/core/hot_reload_guard.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';
import 'package:flutter_adapt_kit/entry/adapt_kit.dart';
import 'package:flutter_adapt_kit/safe/notch_classifier.dart';

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
      expect(state.notchInfo.topInset, 99);

      state.resetNotch();
      expect(state.notchInfo.topInset, 0);
    });
  });
}

class _TestClassifier extends NotchClassifier {
  const _TestClassifier();

  @override
  NotchInfo classify(SystemInfo info) {
    return const NotchInfo(type: NotchType.none);
  }
}
