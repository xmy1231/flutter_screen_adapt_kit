import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screen_adapt_kit/safe/android_classifier.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';

void main() {
  group('AndroidNotchClassifier', () {
    final classifier = AndroidNotchClassifier();

    test('classifies none when padding is zero', () {
      final info = SystemInfo(padding: EdgeInsets.zero);
      final result = classifier.classify(info);
      expect(result.type, NotchType.none);
    });

    test('classifies waterdrop when top between 25-35', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 30, bottom: 0),
        viewPadding: const EdgeInsets.only(top: 30, bottom: 0),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.waterdrop);
    });

    test('classifies holePunch when top > 35', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 40, bottom: 20),
        viewPadding: const EdgeInsets.only(top: 40, bottom: 20),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.holePunch);
    });

    test('status bar only (top <= 25) returns none', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 24),
        viewPadding: const EdgeInsets.only(top: 24),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.none);
    });

    test('edgeToEdge mode: zero padding, non-zero viewPadding', () {
      final info = SystemInfo(
        padding: EdgeInsets.zero,
        viewPadding: const EdgeInsets.only(top: 24),
      );
      final result = classifier.classify(info);
      expect(result.topInset, 24);
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

    test('top=36 → holePunch (crosses waterdrop upper bound)', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 36, bottom: 20),
        viewPadding: const EdgeInsets.only(top: 36, bottom: 20),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.holePunch);
    });

    test('bottom inset present with small top → holePunch', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        viewPadding: const EdgeInsets.only(top: 20, bottom: 30),
      );
      final result = classifier.classify(info);
      expect(result.type, NotchType.holePunch);
      expect(result.bottomInset, 30);
    });

    test('landscape: left > 35 → holePunch', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(left: 40, right: 10),
        logicalSize: const Size(844, 390),
      );
      final result = classifier.classify(info, orientation: Orientation.landscape);
      expect(result.type, NotchType.holePunch);
      expect(result.leftInset, 40);
    });

    test('landscape: left 25-35 → waterdrop', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(left: 30, right: 10),
        logicalSize: const Size(844, 390),
      );
      final result = classifier.classify(info, orientation: Orientation.landscape);
      expect(result.type, NotchType.waterdrop);
    });

    test('landscape: left <= 25 → none', () {
      final info = SystemInfo(
        padding: const EdgeInsets.only(left: 20, right: 20),
        logicalSize: const Size(844, 390),
      );
      final result = classifier.classify(info, orientation: Orientation.landscape);
      expect(result.type, NotchType.none);
    });
  });
}
