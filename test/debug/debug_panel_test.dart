import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/core/hot_reload_guard.dart';
import 'package:flutter_screen_adapt_kit/debug/debug_panel.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';

void main() {
  setUp(() {
    HotReloadGuard.reset();
  });

  group('AdaptDebugPanel', () {
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

    testWidgets('omits notch line when notchType is null', (tester) async {
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
      // No 'Notch:' line when notchType is null
      expect(find.textContaining('Notch:'), findsNothing);
    });

    testWidgets('renders scale with 4 decimal precision', (tester) async {
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
      expect(find.text('Scale: 1.0000'), findsOneWidget);
    });

    testWidgets('drag is clamped to screen bounds (cannot be dragged off-screen)', (tester) async {
      // TDD: panel should not be draggable beyond the right/bottom edges of the screen
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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

      // Find the panel container
      final container = find.byType(Container).first;
      // Get the position before drag
      final positionedBefore = tester.widgetList<Positioned>(find.byType(Positioned)).first;
      final initialLeft = positionedBefore.left!;
      final initialTop = positionedBefore.top!;

      // Try to drag 2000px to the right (way off screen)
      await tester.drag(container, const Offset(2000, 0));
      await tester.pumpAndSettle();

      final positionedAfter = tester.widgetList<Positioned>(find.byType(Positioned)).first;
      final newLeft = positionedAfter.left!;
      final newTop = positionedAfter.top!;

      // Position should have changed
      expect(newLeft, isNot(equals(initialLeft)));
      // But should be clamped to screen width (with some margin for panel width)
      // Default test screen is 800x600, panel content is ~150px wide
      // Without clamp, newLeft would be initialLeft + 2000 = way off screen
      // With clamp, newLeft should be <= 800 - panel_width
      expect(newLeft, lessThanOrEqualTo(800.0),
          reason: 'Panel should not extend beyond right edge');
      // Vertical drag is 0, so top should be unchanged
      expect(newTop, equals(initialTop));
    });

    testWidgets('drag is also clamped to bottom edge', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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

      final container = find.byType(Container).first;
      // Try to drag way down
      await tester.drag(container, const Offset(0, 2000));
      await tester.pumpAndSettle();

      final positioned = tester.widgetList<Positioned>(find.byType(Positioned)).first;
      expect(positioned.top!, lessThanOrEqualTo(600.0),
          reason: 'Panel should not extend beyond bottom edge');
    });

    testWidgets('negative drag (off top/left edge) is clamped to 0', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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

      final container = find.byType(Container).first;
      // Drag up-left (negative direction)
      await tester.drag(container, const Offset(-100, -100));
      await tester.pumpAndSettle();

      final positioned = tester.widgetList<Positioned>(find.byType(Positioned)).first;
      // Should be clamped to 0 (not negative)
      expect(positioned.left!, greaterThanOrEqualTo(0.0));
      expect(positioned.top!, greaterThanOrEqualTo(0.0));
    });
  });

  group('AdaptDebugOverlay', () {
    testWidgets('renders nothing outside AdaptKit context', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptDebugOverlay(),
          ),
        ),
      );
      // Without AdaptKit, adaptScaleResult is null → returns SizedBox.shrink
      expect(find.byType(AdaptDebugPanel), findsNothing);
    });

    testWidgets('renders panel inside AdaptKit context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptKit(
            designSize: const Size(375, 812),
            child: const Scaffold(
              body: AdaptDebugOverlay(),
            ),
          ),
        ),
      );
      // Inside AdaptKit, the overlay should show a real panel
      expect(find.byType(AdaptDebugPanel), findsOneWidget);
      // It should show the design size
      expect(find.textContaining('375'), findsOneWidget);
    });
  });
}
