import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class SystemInfo {
  final Size physicalSize;
  final double dpr;
  final Size logicalSize;
  final EdgeInsets viewPadding;
  final EdgeInsets padding;
  final EdgeInsets viewInsets;
  final double systemTextScale;
  final List<ui.DisplayFeature> displayFeatures;

  const SystemInfo({
    this.physicalSize = Size.zero,
    this.dpr = 1.0,
    this.logicalSize = Size.zero,
    this.viewPadding = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.viewInsets = EdgeInsets.zero,
    this.systemTextScale = 1.0,
    this.displayFeatures = const [],
  });

  bool get isFolded {
    for (final feature in displayFeatures) {
      if (feature.type == ui.DisplayFeatureType.fold ||
          feature.type == ui.DisplayFeatureType.hinge) {
        if (feature.state == ui.DisplayFeatureState.postureHalfOpened) {
          return true;
        }
      }
    }
    return false;
  }

  bool get isFlat {
    for (final feature in displayFeatures) {
      if (feature.type == ui.DisplayFeatureType.fold ||
          feature.type == ui.DisplayFeatureType.hinge) {
        if (feature.state == ui.DisplayFeatureState.postureFlat) {
          return true;
        }
      }
    }
    return displayFeatures.isEmpty;
  }

  Rect? get hingeBounds {
    for (final feature in displayFeatures) {
      if (feature.type == ui.DisplayFeatureType.hinge ||
          feature.type == ui.DisplayFeatureType.fold) {
        return feature.bounds;
      }
    }
    return null;
  }

  Orientation get orientation {
    if (logicalSize.width == 0 || logicalSize.height == 0) {
      return Orientation.portrait;
    }
    return logicalSize.width >= logicalSize.height
        ? Orientation.landscape
        : Orientation.portrait;
  }

  factory SystemInfo.fromFlutterView(ui.FlutterView view) {
    final dpr = view.devicePixelRatio;
    final physicalSize = view.physicalSize;
    final vp = view.padding;
    final displayFeatures = view.displayFeatures;
    return SystemInfo(
      physicalSize: physicalSize,
      dpr: dpr,
      logicalSize: Size(
        physicalSize.width / dpr,
        physicalSize.height / dpr,
      ),
      viewPadding: EdgeInsets.fromViewPadding(vp, dpr),
      padding: EdgeInsets.fromViewPadding(vp, dpr),
      viewInsets: EdgeInsets.fromViewPadding(view.viewInsets, dpr),
      systemTextScale: 1.0,
      displayFeatures: displayFeatures,
    );
  }

  factory SystemInfo.fromMediaQuery(MediaQueryData data) {
    final size = data.size;
    return SystemInfo(
      physicalSize: Size(
        size.width * data.devicePixelRatio,
        size.height * data.devicePixelRatio,
      ),
      dpr: data.devicePixelRatio,
      logicalSize: size,
      viewPadding: data.viewPadding,
      padding: data.padding,
      viewInsets: data.viewInsets,
      systemTextScale: data.textScaler.scale(1.0),
      displayFeatures: data.displayFeatures,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemInfo &&
          physicalSize == other.physicalSize &&
          dpr == other.dpr &&
          logicalSize == other.logicalSize &&
          viewPadding == other.viewPadding &&
          padding == other.padding &&
          viewInsets == other.viewInsets &&
          systemTextScale == other.systemTextScale &&
          listEquals(displayFeatures, other.displayFeatures);

  @override
  int get hashCode => Object.hash(
        physicalSize,
        dpr,
        logicalSize,
        viewPadding,
        padding,
        viewInsets,
        systemTextScale,
        Object.hashAll(displayFeatures),
      );
}
