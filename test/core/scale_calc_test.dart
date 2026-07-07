import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/core/scale_calc.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';

void main() {
  group('ScaleCalc', () {
    const designSize = Size(393, 852);

    test('width strategy', () {
      final info = SystemInfo(logicalSize: Size(390, 844), dpr: 3.0);
      final result = ScaleCalc.compute(info, designSize, AdaptStrategy.width);
      expect(result.scale, closeTo(390 / 393, 0.0001));
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
    });

    test('zero logicalSize returns 1.0 (no scaling)', () {
      final info = SystemInfo(logicalSize: Size.zero, dpr: 3.0);
      final result = ScaleCalc.compute(info, const Size(375, 812), AdaptStrategy.width);
      expect(result.scale, 1.0);
    });

    test('portrait vs landscape with width strategy: different scales', () {
      const design = Size(375, 812);
      // Portrait: 390x844 (typical iPhone)
      final portrait = SystemInfo(logicalSize: const Size(390, 844));
      // Landscape: 844x390 (rotated)
      final landscape = SystemInfo(logicalSize: const Size(844, 390));

      final pScale = ScaleCalc.compute(portrait, design, AdaptStrategy.width).scale;
      final lScale = ScaleCalc.compute(landscape, design, AdaptStrategy.width).scale;

      // Portrait width = 390 vs design 375 → ~1.04
      // Landscape width = 844 vs design 375 → ~2.25
      expect(pScale, closeTo(390 / 375, 0.0001));
      expect(lScale, closeTo(844 / 375, 0.0001));
      expect(lScale, greaterThan(pScale));
    });

    test('height strategy: portrait vs landscape invert which is larger', () {
      const design = Size(375, 812);
      // Portrait: 390x844
      final portrait = SystemInfo(logicalSize: const Size(390, 844));
      // Landscape: 844x390
      final landscape = SystemInfo(logicalSize: const Size(844, 390));

      final pHScale = ScaleCalc.compute(portrait, design, AdaptStrategy.height).scale;
      final lHScale = ScaleCalc.compute(landscape, design, AdaptStrategy.height).scale;

      // Portrait height = 844 vs design 812 → ~1.04
      // Landscape height = 390 vs design 812 → ~0.48
      expect(pHScale, closeTo(844 / 812, 0.0001));
      expect(lHScale, closeTo(390 / 812, 0.0001));
      expect(pHScale, greaterThan(lHScale));
    });

    test('min strategy: portrait (390x844) and landscape (844x390) yield same scale', () {
      const design = Size(375, 812);
      final portrait = SystemInfo(logicalSize: const Size(390, 844));
      final landscape = SystemInfo(logicalSize: const Size(844, 390));

      // min dimension for both is the same: 390
      final pMin = ScaleCalc.compute(portrait, design, AdaptStrategy.min).scale;
      final lMin = ScaleCalc.compute(landscape, design, AdaptStrategy.min).scale;

      // design min is min(375, 812) = 375
      // 390/375 ≈ 1.04
      expect(pMin, closeTo(390 / 375, 0.0001));
      expect(lMin, closeTo(390 / 375, 0.0001));
    });

    test('square design and square logical: all 3 strategies equal', () {
      const design = Size(500, 500);
      final info = SystemInfo(logicalSize: const Size(1000, 1000));

      final w = ScaleCalc.compute(info, design, AdaptStrategy.width);
      final h = ScaleCalc.compute(info, design, AdaptStrategy.height);
      final m = ScaleCalc.compute(info, design, AdaptStrategy.min);

      expect(w.scale, 2.0);
      expect(h.scale, 2.0);
      expect(m.scale, 2.0);
    });

    test('extreme aspect ratio (foldable unfolded)', () {
      // Samsung Galaxy Fold unfolded: ~840x1800
      const design = Size(800, 1200);
      final info = SystemInfo(logicalSize: const Size(840, 1800));

      final w = ScaleCalc.compute(info, design, AdaptStrategy.width);
      final h = ScaleCalc.compute(info, design, AdaptStrategy.height);

      expect(w.scale, closeTo(840 / 800, 0.0001));
      expect(h.scale, closeTo(1800 / 1200, 0.0001));
    });
  });
}
