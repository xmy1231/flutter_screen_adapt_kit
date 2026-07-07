import 'package:flutter/widgets.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';

const double _kStatusBarHeightThreshold = 25.0;
const double _kHolePunchMaxHeight = 29.0;
const double _kWaterdropMinHeight = 30.0;
const double _kWaterdropMaxHeight = 35.0;
const double _kWideNotchMinHeight = 45.0;
const double _kDualScreenBottomThreshold = 20.0;

class HarmonyOSNotchClassifier extends NotchClassifier {
  const HarmonyOSNotchClassifier();

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
    final effectiveTop = top > 0 ? top : info.viewPadding.top;
    final effectiveBottom = bottom > 0 ? bottom : info.viewPadding.bottom;

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

    if (effectiveBottom > _kDualScreenBottomThreshold) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.wideNotch,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    if (effectiveTop > _kStatusBarHeightThreshold && effectiveTop <= _kHolePunchMaxHeight) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.holePunch,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    if (effectiveTop >= _kWaterdropMinHeight && effectiveTop <= _kWaterdropMaxHeight) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.waterdrop,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    if (effectiveTop > _kWaterdropMaxHeight && effectiveTop <= _kWideNotchMinHeight) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.holePunch,
        topInset: effectiveTop,
        bottomInset: effectiveBottom,
      );
    }

    if (effectiveTop > _kWideNotchMinHeight) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.wideNotch,
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
    final left = info.padding.left;
    final right = info.padding.right;
    final effectiveLeft = left > 0 ? left : info.viewPadding.left;
    final effectiveRight = right > 0 ? right : info.viewPadding.right;

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

    if (effectiveLeft > _kStatusBarHeightThreshold && effectiveLeft <= _kHolePunchMaxHeight) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.holePunch,
        leftInset: effectiveLeft,
        rightInset: effectiveRight,
      );
    }

    if (effectiveLeft >= _kWaterdropMinHeight && effectiveLeft <= _kWaterdropMaxHeight) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.waterdrop,
        leftInset: effectiveLeft,
        rightInset: effectiveRight,
      );
    }

    if (effectiveLeft > _kWaterdropMaxHeight && effectiveLeft <= _kWideNotchMinHeight) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.holePunch,
        leftInset: effectiveLeft,
        rightInset: effectiveRight,
      );
    }

    if (effectiveLeft > _kWideNotchMinHeight || effectiveRight > _kDualScreenBottomThreshold) {
      return NotchInfo.fromFoldable(
        info: info,
        type: NotchType.wideNotch,
        leftInset: effectiveLeft,
        rightInset: effectiveRight,
      );
    }

    return NotchInfo.fromFoldable(
      info: info,
      type: NotchType.none,
      leftInset: effectiveLeft,
      rightInset: effectiveRight,
    );
  }
}
