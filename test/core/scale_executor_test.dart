import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/core/scale_executor.dart';
import 'package:flutter_screen_adapt_kit/core/scale_calc.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';

void main() {
  group('ScaleExecutor', () {
    test('apply returns modified ViewConfiguration', () {
      final executor = ScaleExecutor();
      final info = SystemInfo(
        dpr: 3.0,
        logicalSize: const Size(390, 844),
        physicalSize: const Size(1170, 2532),
      );
      const design = Size(393, 852);
      final result = ScaleCalc.compute(info, design, AdaptStrategy.width);

      final config = executor.apply(result, info);

      expect(config.devicePixelRatio, closeTo(3.0 * (390 / 393), 0.0001));
      expect(config.logicalConstraints.maxWidth, closeTo(390 / (390 / 393), 0.01));
    });

    test('apply 1:1 scale returns correct DPR', () {
      final executor = ScaleExecutor();
      final info = SystemInfo(
        dpr: 3.0,
        logicalSize: const Size(393, 852),
        physicalSize: const Size(1179, 2556),
      );
      const design = Size(393, 852);
      final result = ScaleCalc.compute(info, design, AdaptStrategy.width);

      final config = executor.apply(result, info);
      expect(config.devicePixelRatio, 3.0);
    });

    test('apply with height strategy: adaptedDpr matches height ratio', () {
      final executor = ScaleExecutor();
      final info = SystemInfo(
        dpr: 2.0,
        logicalSize: const Size(390, 1000),
        physicalSize: const Size(780, 2000),
      );
      const design = Size(390, 800);
      final result = ScaleCalc.compute(info, design, AdaptStrategy.height);

      final config = executor.apply(result, info);
      // scale = 1000/800 = 1.25; adaptedDpr = 2.0 * 1.25 = 2.5
      expect(config.devicePixelRatio, closeTo(2.5, 0.001));
    });

    test('apply with min strategy: scale uses min dimension', () {
      final executor = ScaleExecutor();
      final info = SystemInfo(
        dpr: 3.0,
        logicalSize: const Size(800, 600),  // min = 600
        physicalSize: const Size(2400, 1800),
      );
      const design = Size(400, 300);  // min = 300
      final result = ScaleCalc.compute(info, design, AdaptStrategy.min);

      final config = executor.apply(result, info);
      // scale = 600/300 = 2.0; adaptedDpr = 3.0 * 2.0 = 6.0
      expect(config.devicePixelRatio, closeTo(6.0, 0.001));
    });

    test('apply produces tight BoxConstraints matching physicalSize', () {
      final executor = ScaleExecutor();
      final info = SystemInfo(
        dpr: 3.0,
        logicalSize: const Size(390, 844),
        physicalSize: const Size(1170, 2532),
      );
      const design = Size(390, 844);  // 1:1
      final result = ScaleCalc.compute(info, design, AdaptStrategy.width);

      final config = executor.apply(result, info);
      // BoxConstraints.tight(physicalSize) has min == max
      expect(config.physicalConstraints.minWidth, config.physicalConstraints.maxWidth);
      expect(config.physicalConstraints.minWidth, 1170);
      expect(config.physicalConstraints.minHeight, 2532);
    });

    test('apply preserves devicePixelRatio when zero guard triggers', () {
      // Zero-size guard in ScaleCalc returns 1.0 scale
      final executor = ScaleExecutor();
      final info = SystemInfo(
        dpr: 3.0,
        logicalSize: Size.zero,
        physicalSize: Size.zero,
      );
      const design = Size(375, 812);
      final result = ScaleCalc.compute(info, design, AdaptStrategy.width);

      final config = executor.apply(result, info);
      // scale=1.0, adaptedDpr=3.0
      expect(config.devicePixelRatio, 3.0);
    });
  });
}
