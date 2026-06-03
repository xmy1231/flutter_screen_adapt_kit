import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/safe/harmony_classifier.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';
import 'package:flutter_adapt_kit/safe/notch_classifier.dart';

void main() {
  group('HarmonyOSNotchClassifier', () {
    final classifier = HarmonyOSNotchClassifier();

    test('classifies none when padding is zero', () {
      final info = SystemInfo(padding: EdgeInsets.zero);
      final result = classifier.classify(info);
      expect(result.type, NotchType.none);
    });

    test('classifies holePunch for Huawei punch-hole (top 26)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 26),
        viewPadding: const EdgeInsets.only(top: 26),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.holePunch);
      expect(result.topInset, 26);
    });

    test('classifies waterdrop for smaller notch (top 30-35)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 32),
        viewPadding: const EdgeInsets.only(top: 32),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.waterdrop);
      expect(result.topInset, 32);
    });

    test('status bar only returns none', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 24),
        viewPadding: const EdgeInsets.only(top: 24),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.none);
    });

    test('classifies wideNotch for larger cutout (top > 45)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 48, bottom: 20),
        viewPadding: const EdgeInsets.only(top: 48, bottom: 20),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.wideNotch);
    });
  });
}
