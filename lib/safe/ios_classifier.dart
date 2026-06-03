import 'package:flutter/widgets.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';
import 'package:flutter_adapt_kit/safe/notch_classifier.dart';

class iOSNotchClassifier extends NotchClassifier {
  const iOSNotchClassifier();

  @override
  NotchInfo classify(SystemInfo info) {
    final top = info.padding.top;
    final bottom = info.padding.bottom;

    if (top == 0 && bottom == 0) {
      return const NotchInfo(type: NotchType.none);
    }

    if (top >= 50) {
      return NotchInfo(
        type: NotchType.dynamicIsland,
        topInset: top,
        bottomInset: bottom,
      );
    }

    if (top >= 44) {
      return NotchInfo(
        type: NotchType.wideNotch,
        topInset: top,
        bottomInset: bottom,
      );
    }

    if (top <= 24) {
      return const NotchInfo(type: NotchType.none);
    }

    return NotchInfo(
      type: NotchType.wideNotch,
      topInset: top,
      bottomInset: bottom,
    );
  }
}
