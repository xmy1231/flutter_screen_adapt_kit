import 'package:flutter/widgets.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';
import 'package:flutter_adapt_kit/safe/notch_classifier.dart';

class HarmonyOSNotchClassifier extends NotchClassifier {
  const HarmonyOSNotchClassifier();

  @override
  NotchInfo classify(SystemInfo info) {
    final top = info.padding.top;
    final bottom = info.padding.bottom;
    final effectiveTop = top > 0 ? top : info.viewPadding.top;
    final effectiveBottom = bottom > 0 ? bottom : info.viewPadding.bottom;

    if (effectiveTop == 0 && effectiveBottom == 0) {
      return const NotchInfo(type: NotchType.none);
    }

    if (effectiveTop <= 25 && effectiveBottom == 0) {
      return const NotchInfo(type: NotchType.none);
    }

    if (effectiveTop > 25 && effectiveTop <= 29 && effectiveBottom <= 20) {
      return NotchInfo(
        type: NotchType.holePunch,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    if (effectiveTop >= 30 && effectiveTop <= 35) {
      return NotchInfo(
        type: NotchType.waterdrop,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    if (effectiveTop > 35 && effectiveTop <= 45 && effectiveBottom <= 20) {
      return NotchInfo(
        type: NotchType.holePunch,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    if (effectiveTop > 45 || effectiveBottom > 20) {
      return NotchInfo(
        type: NotchType.wideNotch,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    return NotchInfo(
      type: NotchType.none,
      topInset: effectiveTop,
      bottomInset: effectiveBottom,
    );
  }
}
