import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/core/scale_calc.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';

void main() {
  group('ScaleCalc', () {
    const designSize = Size(393, 852);

    test('width strategy', () {
      final info = SystemInfo(logicalSize: Size(390, 844), dpr: 3.0);
      final result = ScaleCalc.compute(info, designSize, AdaptStrategy.width);
      expect(result.scale, closeTo(390 / 393, 0.0001));
      expect(result.adaptedDpr, closeTo(3.0 * (390 / 393), 0.0001));
      expect(result.strategy, AdaptStrategy.width);
    });

    test('height strategy', () {
      final info = SystemInfo(logicalSize: Size(390, 844));
      final result = ScaleCalc.compute(info, designSize, AdaptStrategy.height);
      expect(result.scale, closeTo(844 / 852, 0.0001));
    });

    test('min strategy uses shorter edge', () {
      final info = SystemInfo(logicalSize: Size(390, 844));
      final result = ScaleCalc.compute(info, designSize, AdaptStrategy.min);
      expect(result.scale, closeTo(390 / 393, 0.0001));
    });

    test('scale is 1.0 when sizes match', () {
      final info = SystemInfo(logicalSize: designSize);
      final result = ScaleCalc.compute(info, designSize, AdaptStrategy.width);
      expect(result.scale, 1.0);
    });

    test('ScaleResult value semantics', () {
      final info = SystemInfo(logicalSize: Size(800, 600), dpr: 2.0);
      const design = Size(400, 300);
      final result = ScaleCalc.compute(info, design, AdaptStrategy.min);
      expect(result.scale, 2.0);
      expect(result.designSize, design);
      expect(result.logicalSize, info.logicalSize);
    });

    test('zero designSize returns 1.0 (no scaling)', () {
      final info = SystemInfo(logicalSize: const Size(390, 844), dpr: 3.0);
      final result = ScaleCalc.compute(info, Size.zero, AdaptStrategy.width);
      expect(result.scale, 1.0);
      expect(result.adaptedDpr, 3.0);
    });

    test('zero logicalSize returns 1.0 (no scaling)', () {
      final info = SystemInfo(logicalSize: Size.zero, dpr: 3.0);
      final result = ScaleCalc.compute(info, const Size(375, 812), AdaptStrategy.width);
      expect(result.scale, 1.0);
    });
  });
}
