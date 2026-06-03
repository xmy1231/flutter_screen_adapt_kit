import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';

void main() {
  group('SystemInfo', () {
    test('default constructor sets zero values', () {
      const info = SystemInfo();
      expect(info.physicalSize, Size.zero);
      expect(info.dpr, 1.0);
      expect(info.logicalSize, Size.zero);
      expect(info.viewPadding, EdgeInsets.zero);
      expect(info.padding, EdgeInsets.zero);
      expect(info.viewInsets, EdgeInsets.zero);
      expect(info.systemTextScale, 1.0);
      expect(info.foldState, FoldState.unknown);
    });

    test('equality: same values are equal', () {
      const a = SystemInfo(physicalSize: Size(100, 200), dpr: 2.0);
      const b = SystemInfo(physicalSize: Size(100, 200), dpr: 2.0);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('equality: different values are not equal', () {
      const a = SystemInfo(physicalSize: Size(100, 200));
      const b = SystemInfo(physicalSize: Size(200, 400));
      expect(a, isNot(b));
    });

    test('fromMediaQuery maps all fields correctly', () {
      final mq = MediaQueryData(
        size: const Size(390, 844),
        devicePixelRatio: 3.0,
        padding: const EdgeInsets.only(top: 59, bottom: 34),
        viewPadding: const EdgeInsets.only(top: 59, bottom: 34),
        textScaler: TextScaler.linear(2.0),
      );
      final info = SystemInfo.fromMediaQuery(mq);
      expect(info.logicalSize, const Size(390, 844));
      expect(info.dpr, 3.0);
      expect(info.padding.top, 59);
      expect(info.systemTextScale, 2.0);
    });
  });
}
