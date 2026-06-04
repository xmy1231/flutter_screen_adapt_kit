import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/safe/safe_adapter.dart';
import 'package:flutter_adapt_kit/safe/notch_classifier.dart';

void main() {
  group('SafeAdapter', () {
    testWidgets('renders child without insets in zero safe area', (tester) async {
      await tester.pumpWidget(
        const SafeAdapter(
          notchInfo: NotchInfo.zero,
          child: SizedBox(width: 100, height: 100),
        ),
      );
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('applies top inset padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SafeAdapter(
            notchInfo: NotchInfo(type: NotchType.wideNotch, topInset: 44),
            child: Text('Hello'),
          ),
        ),
      );
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect((padding.padding as EdgeInsets).top, 44);
    });

    testWidgets('SafeMode.none disables all padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SafeAdapter(
            notchInfo: NotchInfo(type: NotchType.wideNotch, topInset: 44),
            mode: SafeMode.none,
            child: Text('Hello'),
          ),
        ),
      );
      expect(find.byType(Padding), findsNothing);
    });

    testWidgets('SafeMode.maximum uses notchInfo insets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SafeAdapter(
            notchInfo: NotchInfo(type: NotchType.wideNotch, topInset: 44, bottomInset: 34),
            mode: SafeMode.maximum,
            child: Text('Hello'),
          ),
        ),
      );
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect((padding.padding as EdgeInsets).top, 44);
      expect((padding.padding as EdgeInsets).bottom, 34);
    });

    testWidgets('SafeMode.auto adds padding when notch present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SafeAdapter(
            notchInfo: NotchInfo(type: NotchType.wideNotch, topInset: 44),
            mode: SafeMode.auto,
            child: Text('Hello'),
          ),
        ),
      );
      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets('SafeMode.auto skips padding when notch is none', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SafeAdapter(
            notchInfo: NotchInfo.zero,
            mode: SafeMode.auto,
            child: Text('Hello'),
          ),
        ),
      );
      expect(find.byType(Padding), findsNothing);
    });

    testWidgets('SafeMode.minimum uses only top/bottom insets, ignores left/right', (tester) async {
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
            mode: SafeMode.minimum,
            child: Text('Hello'),
          ),
        ),
      );
      final padding = tester.widget<Padding>(find.byType(Padding));
      final insets = padding.padding as EdgeInsets;
      expect(insets.top, 44);
      expect(insets.bottom, 34);
      expect(insets.left, 0);
      expect(insets.right, 0);
    });
  });
}
