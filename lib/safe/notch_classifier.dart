import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';

enum NotchType {
  none,
  wideNotch,
  dynamicIsland,
  holePunch,
  waterdrop,
  doubleCutout,
  cameraUnder,
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
}

class NotchInfo {
  final NotchType type;
  final double topInset;
  final double bottomInset;
  final double leftInset;
  final double rightInset;
  final List<ui.Rect> cutoutRects;

  const NotchInfo({
    required this.type,
    this.topInset = 0,
    this.bottomInset = 0,
    this.leftInset = 0,
    this.rightInset = 0,
    this.cutoutRects = const [],
  });

  EdgeInsets get insets => EdgeInsets.only(
        top: topInset,
        bottom: bottomInset,
        left: leftInset,
        right: rightInset,
      );

  static const zero = NotchInfo(type: NotchType.none);
}

abstract class NotchClassifier {
  const NotchClassifier();
  NotchInfo classify(SystemInfo info);
}
