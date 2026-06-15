import 'package:flutter/widgets.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';

class AndroidNotchClassifier extends NotchClassifier {
  const AndroidNotchClassifier();

  @override
  NotchInfo classify(SystemInfo info, {Orientation? orientation}) {
    final effectiveOrientation = orientation ?? info.orientation;

    if (effectiveOrientation == Orientation.landscape) {
      return _classifyLandscape(info);
    }
    return _classifyPortrait(info);
  }

  NotchInfo _classifyPortrait(SystemInfo info) {
    final padding = info.padding;
    final viewPadding = info.viewPadding;

    final effectiveTop = padding.top > 0 ? padding.top : viewPadding.top;
    final effectiveBottom = padding.bottom > 0 ? padding.bottom : viewPadding.bottom;

    if (effectiveTop == 0 && effectiveBottom == 0) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.none,
        topInset: 0,
        bottomInset: 0,
      );
    }

    if (effectiveTop <= 25 && effectiveBottom == 0) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.none,
        topInset: effectiveTop,
        bottomInset: 0,
      );
    }

    if (effectiveTop <= 25 && effectiveBottom > 0) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.holePunch,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    if (effectiveTop > 25 && effectiveTop <= 35) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.waterdrop,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    if (effectiveTop > 35) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.holePunch,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    return NotchInfo.fromFoldable(
      info: info,
      type: NotchType.none,
      topInset: effectiveTop,
      bottomInset: effectiveBottom,
    );
  }

  NotchInfo _classifyLandscape(SystemInfo info) {
    final padding = info.padding;
    final viewPadding = info.viewPadding;

    final effectiveLeft = padding.left > 0 ? padding.left : viewPadding.left;
    final effectiveRight = padding.right > 0 ? padding.right : viewPadding.right;

    if (effectiveLeft == 0 && effectiveRight == 0) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.none,
        leftInset: 0,
        rightInset: 0,
      );
    }

    if (effectiveLeft <= 25 && effectiveRight <= 25) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.none,
        leftInset: effectiveLeft,
        rightInset: effectiveRight,
      );
    }

    if (effectiveLeft > 25 && effectiveLeft <= 35) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.waterdrop,
        leftInset: effectiveLeft,
        rightInset: effectiveRight,
      );
    }

    if (effectiveRight > 25 && effectiveRight <= 35) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.waterdrop,
        leftInset: effectiveLeft,
        rightInset: effectiveRight,
      );
    }

    return NotchInfo.fromFoldable(
      info: info,
      type: NotchType.holePunch,
      leftInset: effectiveLeft,
      rightInset: effectiveRight,
    );
  }
}
