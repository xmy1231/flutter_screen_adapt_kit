import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

enum FoldState { unknown, folded, halfFolded, unfolded }

class SystemInfo {
  Size physicalSize;
  double dpr;
  Size logicalSize;
  EdgeInsets viewPadding;
  EdgeInsets padding;
  EdgeInsets viewInsets;
  double systemTextScale;
  FoldState foldState;

  SystemInfo({
    this.physicalSize = Size.zero,
    this.dpr = 0,
    this.logicalSize = Size.zero,
    this.viewPadding = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.viewInsets = EdgeInsets.zero,
    this.systemTextScale = 1.0,
    this.foldState = FoldState.unknown,
  });

  factory SystemInfo.fromFlutterView(ui.FlutterView view) {
    final dpr = view.devicePixelRatio;
    final physicalSize = view.physicalSize;
    return SystemInfo(
      physicalSize: physicalSize,
      dpr: dpr,
      logicalSize: Size(
        physicalSize.width / dpr,
        physicalSize.height / dpr,
      ),
      viewPadding: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
      systemTextScale: 1.0,
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
          foldState == other.foldState;

  @override
  int get hashCode => Object.hash(
        physicalSize,
        dpr,
        logicalSize,
        viewPadding,
        padding,
        viewInsets,
        systemTextScale,
        foldState,
      );
}
