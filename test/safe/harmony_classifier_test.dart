import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/safe/harmony_classifier.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';

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

    test('top=25 → none (status bar threshold)', () {
      final info = SystemInfo(padding: const EdgeInsets.only(top: 25));
      final result = classifier.classify(info);
      expect(result.type, NotchType.none);
    });

    test('top=35 → waterdrop (upper bound)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 35, bottom: 0),
        viewPadding: const EdgeInsets.only(top: 35, bottom: 0),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.waterdrop);
    });

    test('top=45 → holePunch (upper bound)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 45, bottom: 0),
        viewPadding: const EdgeInsets.only(top: 45, bottom: 0),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.holePunch);
    });

    test('top=46 → wideNotch (crosses hole-punch threshold)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 46, bottom: 0),
        viewPadding: const EdgeInsets.only(top: 46, bottom: 0),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.wideNotch);
    });

    test('bottom > 20 → wideNotch (dual screen scenario)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 30, bottom: 25),
        viewPadding: const EdgeInsets.only(top: 30, bottom: 25),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.wideNotch);
    });

    test('landscape: left > 45 → wideNotch', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(left: 48, right: 10),
        logicalSize: const Size(844, 390),
      );
      final result = classifier.classify(info, orientation: Orientation.landscape);
      expect(result.type, NotchType.wideNotch);
    });

    test('landscape: left 30-35 → waterdrop', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(left: 32, right: 10),
        logicalSize: const Size(844, 390),
      );
      final result = classifier.classify(info, orientation: Orientation.landscape);
      expect(result.type, NotchType.waterdrop);
    });

    test('landscape: left 26-29 → holePunch', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(left: 27, right: 10),
        logicalSize: const Size(844, 390),
      );
      final result = classifier.classify(info, orientation: Orientation.landscape);
      expect(result.type, NotchType.holePunch);
    });
  });
}
