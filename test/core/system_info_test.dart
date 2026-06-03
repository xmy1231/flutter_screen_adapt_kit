import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';

void main() {
  group('SystemInfo', () {
    test('default constructor sets zero values', () {
      final info = SystemInfo();
      expect(info.physicalSize, Size.zero);
      expect(info.dpr, 0);
      expect(info.logicalSize, Size.zero);
      expect(info.viewPadding, EdgeInsets.zero);
      expect(info.padding, EdgeInsets.zero);
      expect(info.viewInsets, EdgeInsets.zero);
      expect(info.systemTextScale, 1.0);
    });
  });
}
