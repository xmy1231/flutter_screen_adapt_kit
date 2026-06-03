import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/text/text_scaler.dart';

void main() {
  group('TextScaler', () {
    test('scale mode with default system scale', () {
      final factor = TextScaleDecider.compute(
        uiScale: 1.2,
        systemTextScale: 1.0,
        behavior: TextBehavior.scale,
        supportSystemTextScale: true,
      );
      expect(factor, 1.2);
    });

    test('scale mode without system scale', () {
      final factor = TextScaleDecider.compute(
        uiScale: 1.2,
        systemTextScale: 1.5,
        behavior: TextBehavior.scale,
        supportSystemTextScale: false,
      );
      expect(factor, 1.2);
    });

    test('scale mode with both scales', () {
      final factor = TextScaleDecider.compute(
        uiScale: 1.2,
        systemTextScale: 1.5,
        behavior: TextBehavior.scale,
        supportSystemTextScale: true,
      );
      expect(factor, closeTo(1.2 * 1.5, 0.0001));
    });

    test('system mode ignores ui scale', () {
      final factor = TextScaleDecider.compute(
        uiScale: 1.2,
        systemTextScale: 1.5,
        behavior: TextBehavior.system,
      );
      expect(factor, 1.5);
    });

    test('fixed mode always returns 1.0', () {
      final factor = TextScaleDecider.compute(
        uiScale: 1.2,
        systemTextScale: 1.5,
        behavior: TextBehavior.fixed,
      );
      expect(factor, 1.0);
    });
  });
}
