import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';

void main() {
  group('SystemInfo', () {
    test('default constructor sets zero values', () {
      const info = SystemInfo();
      expect(info.physicalSize, Size.zero);
      expect(info.dpr, 1.0);
      expect(info.logicalSize, Size.zero);
      expect(info.viewPadding, EdgeInsets.zero);
      expect(info.padding, EdgeInsets.zero);
      expect(info.viewInsets, EdgeInsets.zero);
      expect(info.systemTextScale, 1.0);
    });

    test('equality: same values are equal', () {
      const a = SystemInfo(physicalSize: Size(100, 200), dpr: 2.0);
      const b = SystemInfo(physicalSize: Size(100, 200), dpr: 2.0);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('equality: different values are not equal', () {
      const a = SystemInfo(physicalSize: Size(100, 200));
      const b = SystemInfo(physicalSize: Size(200, 400));
      expect(a, isNot(b));
    });

    test('fromMediaQuery maps all fields correctly', () {
      final mq = MediaQueryData(
        size: const Size(390, 844),
        devicePixelRatio: 3.0,
        padding: const EdgeInsets.only(top: 59, bottom: 34),
        viewPadding: const EdgeInsets.only(top: 59, bottom: 34),
        textScaler: TextScaler.linear(2.0),
      );
      final info = SystemInfo.fromMediaQuery(mq);
      expect(info.logicalSize, const Size(390, 844));
      expect(info.dpr, 3.0);
      expect(info.padding.top, 59);
      expect(info.systemTextScale, 2.0);
    });

    test('fromFlutterView computes logicalSize from physicalSize / dpr', () {
      final view = TestFlutterView(
        devicePixelRatio: 3.0,
        physicalSize: const Size(1170, 2532),
      );
      final info = SystemInfo.fromFlutterView(view);
      expect(info.physicalSize, const Size(1170, 2532));
      expect(info.dpr, 3.0);
      expect(info.logicalSize, const Size(390, 844));
    });

    test('fromFlutterView with zero size', () {
      final view = TestFlutterView(
        devicePixelRatio: 1.0,
        physicalSize: Size.zero,
      );
      final info = SystemInfo.fromFlutterView(view);
      expect(info.physicalSize, Size.zero);
      expect(info.logicalSize, Size.zero);
    });

    test('fromFlutterView with non-integer dpr', () {
      final view = TestFlutterView(
        devicePixelRatio: 2.625,
        physicalSize: const Size(1029.6, 2227.2),
      );
      final info = SystemInfo.fromFlutterView(view);
      // 1029.6 / 2.625 ≈ 392.23
      expect(info.logicalSize.width, closeTo(392.23, 0.01));
    });

    test('fromFlutterView: high-dpr foldable screen ratio', () {
      // Mate X3 unfolded: 2496 x 2224 physical, 3.0 dpr
      final view = TestFlutterView(
        devicePixelRatio: 3.0,
        physicalSize: const Size(2496, 2224),
      );
      final info = SystemInfo.fromFlutterView(view);
      // logical: 832 x 741.33
      expect(info.logicalSize.width, 832.0);
      expect(info.logicalSize.height, closeTo(741.33, 0.01));
      expect(info.physicalSize.width, greaterThan(2000));
    });

    test('fromFlutterView: high dpr small device (Apple Watch style)', () {
      // 396x484 logical, 3.0 dpr → 1188x1452 physical
      final view = TestFlutterView(
        devicePixelRatio: 3.0,
        physicalSize: const Size(1188, 1452),
      );
      final info = SystemInfo.fromFlutterView(view);
      expect(info.logicalSize, const Size(396, 484));
    });

    test('fromFlutterView: 1x dpr low-res device', () {
      final view = TestFlutterView(
        devicePixelRatio: 1.0,
        physicalSize: const Size(320, 480),
      );
      final info = SystemInfo.fromFlutterView(view);
      expect(info.logicalSize, const Size(320, 480));
      expect(info.physicalSize, info.logicalSize);
    });

    test('isFlat returns true when no display features', () {
      final view = TestFlutterView(
        devicePixelRatio: 1.0,
        physicalSize: const Size(390, 844),
      );
      final info = SystemInfo.fromFlutterView(view);
      expect(info.isFlat, true);
      expect(info.isFolded, false);
    });

    test('isFlat returns true for postureFlat display feature', () {
      final view = TestFlutterView(
        devicePixelRatio: 1.0,
        physicalSize: const Size(390, 844),
        displayFeatures: [
          TestDisplayFeature(
            bounds: const Rect.fromLTWH(0, 400, 390, 5),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureFlat,
          ),
        ],
      );
      final info = SystemInfo.fromFlutterView(view);
      expect(info.isFlat, true);
      expect(info.isFolded, false);
      expect(info.hingeBounds, const Rect.fromLTWH(0, 400, 390, 5));
    });

    test('isFolded returns true for postureHalfOpened display feature', () {
      final view = TestFlutterView(
        devicePixelRatio: 1.0,
        physicalSize: const Size(390, 844),
        displayFeatures: [
          TestDisplayFeature(
            bounds: const Rect.fromLTWH(0, 400, 390, 5),
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
      );
      final info = SystemInfo.fromFlutterView(view);
      expect(info.isFlat, false);
      expect(info.isFolded, true);
    });

    test('orientation: portrait when height > width', () {
      final view = TestFlutterView(
        devicePixelRatio: 1.0,
        physicalSize: const Size(390, 844),
      );
      final info = SystemInfo.fromFlutterView(view);
      expect(info.orientation, Orientation.portrait);
    });

    test('orientation: landscape when width >= height', () {
      final view = TestFlutterView(
        devicePixelRatio: 1.0,
        physicalSize: const Size(844, 390),
      );
      final info = SystemInfo.fromFlutterView(view);
      expect(info.orientation, Orientation.landscape);
    });

    test('displayFeatures are captured correctly', () {
      final displayFeatures = [
        TestDisplayFeature(
          bounds: const Rect.fromLTWH(100, 0, 50, 60),
          type: DisplayFeatureType.cutout,
          state: DisplayFeatureState.unknown,
        ),
      ];
      final view = TestFlutterView(
        devicePixelRatio: 1.0,
        physicalSize: const Size(390, 844),
        displayFeatures: displayFeatures,
      );
      final info = SystemInfo.fromFlutterView(view);
      expect(info.displayFeatures.length, 1);
      expect(info.displayFeatures[0].type, DisplayFeatureType.cutout);
    });

    test('fromMediaQuery captures displayFeatures', () {
      final displayFeatures = [
        TestDisplayFeature(
          bounds: const Rect.fromLTWH(100, 0, 50, 60),
          type: DisplayFeatureType.cutout,
          state: DisplayFeatureState.unknown,
        ),
      ];
      final mq = MediaQueryData(
        size: const Size(390, 844),
        devicePixelRatio: 3.0,
        displayFeatures: displayFeatures,
      );
      final info = SystemInfo.fromMediaQuery(mq);
      expect(info.displayFeatures.length, 1);
    });
  });
}

class TestFlutterView implements FlutterView {
  final double devicePixelRatio;
  final Size physicalSize;
  final List<DisplayFeature> displayFeatures;

  TestFlutterView({
    required this.devicePixelRatio,
    required this.physicalSize,
    this.displayFeatures = const [],
  });

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName;
    if (memberName == #padding || memberName == #viewInsets) {
      return ViewPadding.zero;
    }
    return super.noSuchMethod(invocation);
  }
}

class TestDisplayFeature implements DisplayFeature {
  @override
  final Rect bounds;
  @override
  final DisplayFeatureType type;
  @override
  final DisplayFeatureState state;

  const TestDisplayFeature({
    required this.bounds,
    required this.type,
    required this.state,
  });
}

