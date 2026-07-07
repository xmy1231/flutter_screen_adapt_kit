import 'package:flutter/widgets.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';

const double _kStatusBarHeightThreshold = 25.0;
const double _kWaterdropMaxHeight = 35.0;

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

    if (effectiveTop <= _kStatusBarHeightThreshold && effectiveBottom == 0) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.none,
        topInset: effectiveTop,
        bottomInset: 0,
      );
    }

    if (effectiveTop <= _kStatusBarHeightThreshold && effectiveBottom > 0) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.holePunch,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    if (effectiveTop > _kStatusBarHeightThreshold && effectiveTop <= _kWaterdropMaxHeight) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.waterdrop,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    if (effectiveTop > _kWaterdropMaxHeight) {
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

    if (effectiveLeft <= _kStatusBarHeightThreshold && effectiveRight <= _kStatusBarHeightThreshold) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.none,
        leftInset: effectiveLeft,
        rightInset: effectiveRight,
      );
    }

    if (effectiveLeft > _kStatusBarHeightThreshold && effectiveLeft <= _kWaterdropMaxHeight) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.waterdrop,
        leftInset: effectiveLeft,
        rightInset: effectiveRight,
      );
    }

    if (effectiveRight > _kStatusBarHeightThreshold && effectiveRight <= _kWaterdropMaxHeight) {
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
