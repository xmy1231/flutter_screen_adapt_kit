import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/safe/ios_classifier.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';

void main() {
  group('IOSNotchClassifier', () {
    final classifier = IOSNotchClassifier();

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

    test('top=49 → wideNotch (below dynamic island threshold)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 49, bottom: 34),
        viewPadding: const EdgeInsets.only(top: 49, bottom: 34),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.wideNotch);
    });

    test('top=50 → dynamicIsland (at threshold)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 50, bottom: 34),
        viewPadding: const EdgeInsets.only(top: 50, bottom: 34),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.dynamicIsland);
    });

    test('top=24 → none (exact status bar boundary)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 24, bottom: 0),
        viewPadding: const EdgeInsets.only(top: 24, bottom: 0),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.none);
    });

    test('landscape: left >= 50 → dynamicIsland', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(left: 55, right: 55),
        logicalSize: const Size(844, 390),
      );
      final result = classifier.classify(info, orientation: Orientation.landscape);
      expect(result.type, NotchType.dynamicIsland);
      expect(result.leftInset, 55);
      expect(result.rightInset, 55);
    });

    test('landscape: left >= 44 → wideNotch', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(left: 48, right: 48),
        logicalSize: const Size(844, 390),
      );
      final result = classifier.classify(info, orientation: Orientation.landscape);
      expect(result.type, NotchType.wideNotch);
    });

    test('landscape: none when no horizontal insets', () {
      final info = SystemInfo(
        padding: EdgeInsets.zero,
        logicalSize: const Size(844, 390),
      );
      final result = classifier.classify(info, orientation: Orientation.landscape);
      expect(result.type, NotchType.none);
    });
  });
}
