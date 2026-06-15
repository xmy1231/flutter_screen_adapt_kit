import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';

void main() {
  group('NotchInfo', () {
    test('default constructor', () {
      const info = NotchInfo(type: NotchType.none);
      expect(info.type, NotchType.none);
      expect(info.topInset, 0);
      expect(info.bottomInset, 0);
      expect(info.cutoutRects, isEmpty);
    });

    test('NotchInfo.insets returns correct EdgeInsets', () {
      const info = NotchInfo(
        type: NotchType.wideNotch,
        topInset: 44,
        bottomInset: 34,
        leftInset: 10,
        rightInset: 5,
      );
      expect(info.insets, const EdgeInsets.only(top: 44, bottom: 34, left: 10, right: 5));
    });

    test('NotchInfo.zero is a const with zero insets', () {
      expect(NotchInfo.zero.type, NotchType.none);
      expect(NotchInfo.zero.insets, EdgeInsets.zero);
    });
  });
}
