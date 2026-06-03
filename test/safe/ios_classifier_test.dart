import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/safe/ios_classifier.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';
import 'package:flutter_adapt_kit/safe/notch_classifier.dart';

void main() {
  group('iOSNotchClassifier', () {
    final classifier = iOSNotchClassifier();

    test('classifies none when padding is zero', () {
      final info = SystemInfo(padding: EdgeInsets.zero);
      final result = classifier.classify(info);
      expect(result.type, NotchType.none);
    });

    test('classifies dynamic island (top ~59, bottom ~34)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 59, bottom: 34),
        viewPadding: const EdgeInsets.only(top: 59, bottom: 34),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.dynamicIsland);
      expect(result.topInset, 59);
      expect(result.bottomInset, 34);
    });

    test('classifies wideNotch (top > 44)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 44, bottom: 34),
        viewPadding: const EdgeInsets.only(top: 44, bottom: 34),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.wideNotch);
    });

    test('classifies none for old iPhone with home button (top 20)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 20, bottom: 0),
        viewPadding: const EdgeInsets.only(top: 20, bottom: 0),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.none);
    });
  });
}
