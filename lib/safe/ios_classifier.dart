import 'package:flutter/widgets.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';

class IOSNotchClassifier extends NotchClassifier {
  const IOSNotchClassifier();

  @override
  NotchInfo classify(SystemInfo info, {Orientation? orientation}) {
    final effectiveOrientation = orientation ?? info.orientation;

    if (effectiveOrientation == Orientation.landscape) {
      return _classifyLandscape(info);
    }
    return _classifyPortrait(info);
  }

  NotchInfo _classifyPortrait(SystemInfo info) {
    final top = info.padding.top;
    final bottom = info.padding.bottom;

    if (top == 0 && bottom == 0) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.none,
        topInset: 0,
        bottomInset: 0,
      );
    }

    if (top >= 50) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.dynamicIsland,
        topInset: top,
        bottomInset: bottom,
      );
    }

    if (top >= 44) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.wideNotch,
        topInset: top,
        bottomInset: bottom,
      );
    }

    if (top <= 24) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.none,
        topInset: top,
        bottomInset: bottom,
      );
    }

    return NotchInfo.fromFoldable(
      info: info,
      type: NotchType.wideNotch,
      topInset: top,
      bottomInset: bottom,
    );
  }

  NotchInfo _classifyLandscape(SystemInfo info) {
    final left = info.padding.left;
    final right = info.padding.right;
    final top = info.padding.top;
    final bottom = info.padding.bottom;

    final maxHorizontalInset = left > right ? left : right;

    if (maxHorizontalInset == 0 && top == 0 && bottom == 0) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.none,
        topInset: 0,
        bottomInset: 0,
        leftInset: 0,
        rightInset: 0,
      );
    }

    if (left >= 50 || right >= 50) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.dynamicIsland,
        topInset: top,
        bottomInset: bottom,
        leftInset: left,
        rightInset: right,
      );
    }

    if (left >= 44 || right >= 44) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.wideNotch,
        topInset: top,
        bottomInset: bottom,
        leftInset: left,
        rightInset: right,
      );
    }

    return NotchInfo.fromFoldable(
      info: info,
      type: NotchType.wideNotch,
      topInset: top,
      bottomInset: bottom,
      leftInset: left,
      rightInset: right,
    );
  }
}
