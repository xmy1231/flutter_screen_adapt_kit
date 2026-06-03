import 'package:flutter/widgets.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';

enum AdaptStrategy { width, height, min }

class ScaleResult {
  final double scale;
  final double adaptedDpr;
  final AdaptStrategy strategy;
  final Size designSize;
  final Size logicalSize;

  const ScaleResult({
    required this.scale,
    required this.adaptedDpr,
    required this.strategy,
    required this.designSize,
    required this.logicalSize,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScaleResult &&
          scale == other.scale &&
          adaptedDpr == other.adaptedDpr &&
          strategy == other.strategy &&
          designSize == other.designSize &&
          logicalSize == other.logicalSize;

  @override
  int get hashCode => Object.hash(scale, adaptedDpr, strategy, designSize, logicalSize);
}

class ScaleCalc {
  static ScaleResult compute(
    SystemInfo info,
    Size designSize,
    AdaptStrategy strategy,
  ) {
    final logicalSize = info.logicalSize;
    final scale = _calculateScale(logicalSize, designSize, strategy);
    return ScaleResult(
      scale: scale,
      adaptedDpr: info.dpr * scale,
      strategy: strategy,
      designSize: designSize,
      logicalSize: logicalSize,
    );
  }

  static double _calculateScale(
    Size logicalSize,
    Size designSize,
    AdaptStrategy strategy,
  ) {
    switch (strategy) {
      case AdaptStrategy.width:
        return logicalSize.width / designSize.width;
      case AdaptStrategy.height:
        return logicalSize.height / designSize.height;
      case AdaptStrategy.min:
        final logicalMin =
            logicalSize.width < logicalSize.height
                ? logicalSize.width
                : logicalSize.height;
        final designMin =
            designSize.width < designSize.height
                ? designSize.width
                : designSize.height;
        return logicalMin / designMin;
    }
  }
}
