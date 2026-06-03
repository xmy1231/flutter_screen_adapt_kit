import 'package:flutter/widgets.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';
import 'package:flutter_adapt_kit/safe/notch_classifier.dart';

class AndroidNotchClassifier extends NotchClassifier {
  const AndroidNotchClassifier();

  @override
  NotchInfo classify(SystemInfo info) {
    final padding = info.padding;
    final viewPadding = info.viewPadding;

    final effectiveTop = padding.top > 0 ? padding.top : viewPadding.top;
    final effectiveBottom = padding.bottom > 0 ? padding.bottom : viewPadding.bottom;

    if (effectiveTop == 0 && effectiveBottom == 0) {
      return const NotchInfo(type: NotchType.none);
    }

    if (effectiveTop <= 25 && effectiveBottom == 0) {
      return NotchInfo(type: NotchType.none, topInset: effectiveTop);
    }

    final bottomInset = effectiveBottom;

    if (effectiveTop > 25 && effectiveTop <= 35) {
      return NotchInfo(
        type: NotchType.waterdrop,
        topInset: effectiveTop,
        bottomInset: bottomInset,
      );
    }

    if (effectiveTop > 35) {
      return NotchInfo(
        type: NotchType.holePunch,
        topInset: effectiveTop,
        bottomInset: bottomInset,
      );
    }

    return NotchInfo(
      type: NotchType.none,
      bottomInset: bottomInset,
    );
  }
}
