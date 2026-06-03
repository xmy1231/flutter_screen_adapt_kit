import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/core/scale_executor.dart';
import 'package:flutter_adapt_kit/core/scale_calc.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';

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
  });
}
