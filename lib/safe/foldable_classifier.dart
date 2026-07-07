import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';
import 'package:flutter_screen_adapt_kit/safe/ios_classifier.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';

class FoldableClassifier extends NotchClassifier {
  final NotchClassifier baseClassifier;

  const FoldableClassifier({
    this.baseClassifier = const IOSNotchClassifier(),
  });

  @override
  NotchInfo classify(SystemInfo info, {Orientation? orientation}) {
    final effectiveOrientation = orientation ?? info.orientation;

    final notchInfo = baseClassifier.classify(info, orientation: effectiveOrientation);

    final cutoutRects = <ui.Rect>[];
    Rect? hingeBounds;
    FoldState? foldState;

    for (final feature in info.displayFeatures) {
      switch (feature.type) {
        case ui.DisplayFeatureType.cutout:
          cutoutRects.add(feature.bounds);
        case ui.DisplayFeatureType.hinge:
        case ui.DisplayFeatureType.fold:
          hingeBounds = feature.bounds;
          switch (feature.state) {
            case ui.DisplayFeatureState.postureFlat:
              foldState = FoldState.flat;
            case ui.DisplayFeatureState.postureHalfOpened:
              foldState = FoldState.halfOpened;
            default:
              foldState = FoldState.unknown;
          }
        default:
          break;
      }
    }

    if (cutoutRects.isEmpty && hingeBounds == null && foldState == null) {
      foldState = FoldState.unknown;
    }

    return NotchInfo(
      type: notchInfo.type,
      topInset: notchInfo.topInset,
      bottomInset: notchInfo.bottomInset,
      leftInset: notchInfo.leftInset,
      rightInset: notchInfo.rightInset,
      cutoutRects: cutoutRects.isNotEmpty ? cutoutRects : notchInfo.cutoutRects,
      foldState: foldState ?? notchInfo.foldState,
      hingeBounds: hingeBounds ?? notchInfo.hingeBounds,
      orientation: effectiveOrientation,
    );
  }

  static bool isFoldableDevice(SystemInfo info) {
    for (final feature in info.displayFeatures) {
      if (feature.type == ui.DisplayFeatureType.fold ||
          feature.type == ui.DisplayFeatureType.hinge) {
        return true;
      }
    }
    return false;
  }

  static FoldState? getFoldPosture(SystemInfo info) {
    for (final feature in info.displayFeatures) {
      if (feature.type == ui.DisplayFeatureType.fold ||
          feature.type == ui.DisplayFeatureType.hinge) {
        switch (feature.state) {
          case ui.DisplayFeatureState.postureFlat:
            return FoldState.flat;
          case ui.DisplayFeatureState.postureHalfOpened:
            return FoldState.halfOpened;
          default:
            return FoldState.unknown;
        }
      }
    }
    return null;
  }
}