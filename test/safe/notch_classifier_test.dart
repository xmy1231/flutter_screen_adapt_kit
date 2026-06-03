import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/safe/notch_classifier.dart';

void main() {
  group('NotchInfo', () {
    test('default constructor', () {
      const info = NotchInfo(type: NotchType.none);
      expect(info.type, NotchType.none);
      expect(info.topInset, 0);
      expect(info.bottomInset, 0);
      expect(info.cutoutRects, isEmpty);
    });
  });
}
