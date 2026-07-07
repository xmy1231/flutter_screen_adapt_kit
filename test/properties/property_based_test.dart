import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/core/scale_calc.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';

const int _iterations = 100;

Size _randomSize(math.Random r, {double min = 100, double max = 5000}) {
  return Size(
    min + r.nextDouble() * (max - min),
    min + r.nextDouble() * (max - min),
  );
}

double _randomDpr(math.Random r) {
  // Common DPRs: 1.0, 1.5, 2.0, 2.625, 2.75, 3.0, 3.5
  final values = [1.0, 1.5, 2.0, 2.625, 2.75, 3.0, 3.5];
  return values[r.nextInt(values.length)];
}

double _randomTop(math.Random r) {
  return r.nextDouble() * 80;
}

double _randomBottom(math.Random r) {
  return r.nextDouble() * 40;
}

void main() {
  final r = math.Random(42); // fixed seed for reproducibility

  group('Property: ScaleCalc', () {
    test('width strategy: scale = logicalSize.width / designSize.width', () {
      for (var i = 0; i < _iterations; i++) {
        final logical = _randomSize(r);
        final design = _randomSize(r);
        final dpr = _randomDpr(r);
        final info = SystemInfo(logicalSize: logical, dpr: dpr);
        final result = ScaleCalc.compute(info, design, AdaptStrategy.width);

        expect(result.scale, closeTo(logical.width / design.width, 0.0001),
            reason: 'iter $i: logical=$logical, design=$design');
      }
    });

    test('height strategy: scale = logicalSize.height / designSize.height', () {
      for (var i = 0; i < _iterations; i++) {
        final logical = _randomSize(r);
        final design = _randomSize(r);
        final info = SystemInfo(logicalSize: logical);
        final result = ScaleCalc.compute(info, design, AdaptStrategy.height);

        expect(result.scale, closeTo(logical.height / design.height, 0.0001));
      }
    });

    test('min strategy: scale = min(logical) / min(design)', () {
      for (var i = 0; i < _iterations; i++) {
        final logical = _randomSize(r);
        final design = _randomSize(r);
        final info = SystemInfo(logicalSize: logical);
        final result = ScaleCalc.compute(info, design, AdaptStrategy.min);

        final logicalMin = math.min(logical.width, logical.height);
        final designMin = math.min(design.width, design.height);
        expect(result.scale, closeTo(logicalMin / designMin, 0.0001));
      }
    });

    test('scale is positive for non-zero valid inputs', () {
      for (var i = 0; i < _iterations; i++) {
        final logical = _randomSize(r);
        final design = _randomSize(r);
        final info = SystemInfo(logicalSize: logical);
        final result = ScaleCalc.compute(info, design, AdaptStrategy.width);

        expect(result.scale, greaterThanOrEqualTo(0.0));
      }
    });

    test('scale is 1.0 when logical == design (width strategy)', () {
      for (var i = 0; i < 10; i++) {
        final same = _randomSize(r);
        final info = SystemInfo(logicalSize: same);
        final result = ScaleCalc.compute(info, same, AdaptStrategy.width);

        expect(result.scale, closeTo(1.0, 0.0001));
      }
    });

    test('ScaleResult equality is value-based', () {
      for (var i = 0; i < 20; i++) {
        final logical = _randomSize(r);
        final design = _randomSize(r);
        final info = SystemInfo(logicalSize: logical);
        final a = ScaleCalc.compute(info, design, AdaptStrategy.width);
        final b = ScaleCalc.compute(info, design, AdaptStrategy.width);

        expect(a, b);
        expect(a.hashCode, b.hashCode);
      }
    });

    test('strategy field reflects parameter', () {
      for (var i = 0; i < 5; i++) {
        final logical = _randomSize(r);
        final design = _randomSize(r);
        final info = SystemInfo(logicalSize: logical);

        final w = ScaleCalc.compute(info, design, AdaptStrategy.width);
        final h = ScaleCalc.compute(info, design, AdaptStrategy.height);
        final m = ScaleCalc.compute(info, design, AdaptStrategy.min);

        expect(w.strategy, AdaptStrategy.width);
        expect(h.strategy, AdaptStrategy.height);
        expect(m.strategy, AdaptStrategy.min);
      }
    });
  });

  group('Property: SystemInfo', () {
    test('equality is reflexive', () {
      for (var i = 0; i < 20; i++) {
        final size = _randomSize(r);
        final dpr = _randomDpr(r);
        final info = SystemInfo(physicalSize: size, dpr: dpr);
        expect(info, info);
      }
    });

    test('fromMediaQuery fields are consistent with input data', () {
      for (var i = 0; i < _iterations; i++) {
        final logical = _randomSize(r);
        final dpr = _randomDpr(r);
        final top = _randomTop(r);
        final bottom = _randomBottom(r);
        final mq = MediaQueryData(
          size: logical,
          devicePixelRatio: dpr,
          padding: EdgeInsets.only(top: top, bottom: bottom),
          viewPadding: EdgeInsets.only(top: top, bottom: bottom),
          viewInsets: EdgeInsets.zero,
          textScaler: TextScaler.linear(1.0),
        );
        final info = SystemInfo.fromMediaQuery(mq);

        expect(info.logicalSize, logical);
        expect(info.dpr, dpr);
        expect(info.padding.top, top);
        expect(info.padding.bottom, bottom);
      }
    });

    test('hashCode is consistent with equality', () {
      for (var i = 0; i < 20; i++) {
        final size = _randomSize(r);
        final dpr = _randomDpr(r);
        final a = SystemInfo(physicalSize: size, dpr: dpr);
        final b = SystemInfo(physicalSize: size, dpr: dpr);
        expect(a == b, isTrue);
        expect(a.hashCode, b.hashCode);
      }
    });
  });

  group('Property: NotchInfo', () {
    test('insets getter matches constructor fields', () {
      for (var i = 0; i < _iterations; i++) {
        final top = r.nextDouble() * 100;
        final bottom = r.nextDouble() * 50;
        final left = r.nextDouble() * 30;
        final right = r.nextDouble() * 30;
        final info = NotchInfo(
          type: NotchType.wideNotch,
          topInset: top,
          bottomInset: bottom,
          leftInset: left,
          rightInset: right,
        );
        final insets = info.insets;

        expect(insets.top, top);
        expect(insets.bottom, bottom);
        expect(insets.left, left);
        expect(insets.right, right);
      }
    });

    test('NotchInfo.zero insets are all zero', () {
      for (var i = 0; i < 5; i++) {
        // NotchInfo.zero is const, verify invariants
        expect(NotchInfo.zero.insets, EdgeInsets.zero);
        expect(NotchInfo.zero.type, NotchType.none);
      }
    });
  });
}
