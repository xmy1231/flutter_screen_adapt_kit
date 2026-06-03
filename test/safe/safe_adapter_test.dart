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
  });
}
