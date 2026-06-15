import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';

enum NotchType {
  none,
  wideNotch,
  dynamicIsland,
  holePunch,
  waterdrop,
  doubleCutout,
  cameraUnder,
}

enum FoldState {
  flat,
  halfOpened,
  unknown,
}

class NotchOverride {
  final NotchType type;
  final double topInset;
  final double bottomInset;
  final double leftInset;
  final double rightInset;

  const NotchOverride({
    required this.type,
    this.topInset = 0,
    this.bottomInset = 0,
    this.leftInset = 0,
    this.rightInset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotchOverride &&
          type == other.type &&
          topInset == other.topInset &&
          bottomInset == other.bottomInset &&
          leftInset == other.leftInset &&
          rightInset == other.rightInset;

  @override
  int get hashCode => Object.hash(
        type,
        topInset,
        bottomInset,
        leftInset,
        rightInset,
      );
}

class NotchInfo {
  final NotchType type;
  final double topInset;
  final double bottomInset;
  final double leftInset;
  final double rightInset;
  final List<ui.Rect> cutoutRects;
  final FoldState? foldState;
  final Rect? hingeBounds;
  final Orientation? orientation;

  const NotchInfo({
    required this.type,
    this.topInset = 0,
    this.bottomInset = 0,
    this.leftInset = 0,
    this.rightInset = 0,
    this.cutoutRects = const [],
    this.foldState,
    this.hingeBounds,
    this.orientation,
  });

  EdgeInsets get insets => EdgeInsets.only(
        top: topInset,
        bottom: bottomInset,
        left: leftInset,
        right: rightInset,
      );

  static const zero = NotchInfo(type: NotchType.none);

  factory NotchInfo.fromFoldable({
    required SystemInfo info,
    required NotchType type,
    double topInset = 0,
    double bottomInset = 0,
    double leftInset = 0,
    double rightInset = 0,
  }) {
    final cutoutRects = <ui.Rect>[];
    for (final feature in info.displayFeatures) {
      if (feature.type == ui.DisplayFeatureType.cutout) {
        cutoutRects.add(feature.bounds);
      }
    }

    FoldState? foldState;
    bool foundFoldFeature = false;
    for (final feature in info.displayFeatures) {
      if (feature.type == ui.DisplayFeatureType.fold ||
          feature.type == ui.DisplayFeatureType.hinge) {
        foundFoldFeature = true;
        switch (feature.state) {
          case ui.DisplayFeatureState.postureFlat:
            foldState = FoldState.flat;
          case ui.DisplayFeatureState.postureHalfOpened:
            foldState = FoldState.halfOpened;
          default:
            foldState = FoldState.unknown;
        }
        break;
      }
    }
    if (!foundFoldFeature) {
      foldState = FoldState.unknown;
    }

    return NotchInfo(
      type: type,
      topInset: topInset,
      bottomInset: bottomInset,
      leftInset: leftInset,
      rightInset: rightInset,
      cutoutRects: cutoutRects,
      foldState: foldState,
      hingeBounds: info.hingeBounds,
      orientation: info.orientation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotchInfo &&
          type == other.type &&
          topInset == other.topInset &&
          bottomInset == other.bottomInset &&
          leftInset == other.leftInset &&
          rightInset == other.rightInset &&
          listEquals(cutoutRects, other.cutoutRects) &&
          foldState == other.foldState &&
          hingeBounds == other.hingeBounds &&
          orientation == other.orientation;

  @override
  int get hashCode => Object.hash(
        type,
        topInset,
        bottomInset,
        leftInset,
        rightInset,
        Object.hashAll(cutoutRects),
        foldState,
        hingeBounds,
        orientation,
      );
}

abstract class NotchClassifier {
  const NotchClassifier();
  NotchInfo classify(SystemInfo info, {Orientation? orientation});
}
