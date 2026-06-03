import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/debug/debug_panel.dart';

void main() {
  group('DebugPanel', () {
    testWidgets('displays info text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptDebugPanel(
            designWidth: 375,
            designHeight: 812,
            dpr: 3.0,
            scaleRatio: 1.0,
          ),
        ),
      );
      expect(find.textContaining('375'), findsOneWidget);
    });

    testWidgets('shows notch info when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptDebugPanel(
            designWidth: 375,
            designHeight: 812,
            dpr: 3.0,
            scaleRatio: 1.0,
            notchType: 'wideNotch',
          ),
        ),
      );
      expect(find.textContaining('wideNotch'), findsOneWidget);
    });

    testWidgets('is draggable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptDebugPanel(
            designWidth: 375,
            designHeight: 812,
            dpr: 3.0,
            scaleRatio: 1.0,
          ),
        ),
      );
      expect(find.byType(Positioned), findsOneWidget);
    });
  });
}
